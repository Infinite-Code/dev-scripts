import glob


def run():
    setup_done = False
    dir_pip_packages = '/app/pip-packages/'
    keyword_req = ' INJECT_FROM_REQUIREMENTS:'
    for filename_template in glob.glob('Dockerfile-template.*'):
        print('Processing: {}'.format(filename_template))
        filename_dockerfile = filename_template.replace('-template', '')
        with open(filename_template) as src, \
                open(filename_dockerfile, 'w') as dest:
            for line in src:
                if keyword_req in line:
                    uninstall_dependencies = []
                    if not setup_done:
                        dest.write('RUN mkdir -p {}\n'.format(
                            dir_pip_packages))
                        setup_done = True
                    dockerfile_cmd, filename_req = map(lambda x: x.strip(),
                                                       line.split(keyword_req))

                    filename_req_deps = filename_req.replace(
                        '.txt', '-dependencies.yml')
                    deps_map = {}
                    with open(filename_req_deps) as deps:
                        for dep in map(lambda d: d.strip(), deps):
                            if dep in ['---']:
                                continue
                            package, dependencies = dep.split(':')
                            deps_map[package] = dependencies
                    with open(filename_req) as req:
                        for package in req:
                            package_name = package
                            if '==' in package:
                                package_name = package.split('==')[0]
                            if package_name in deps_map:
                                dd = deps_map[package_name]
                                dest.write(
                                    'RUN apt-get install -y {}\n'.format(dd))
                                for d in dd.split():
                                    if d.endswith('-dev') or d in ['gcc']:
                                        uninstall_dependencies.append(d)
                            dest.write('{} download -d {} {}\n'.format(
                                dockerfile_cmd, dir_pip_packages, package))
                            dest.write(
                                '{} install --find-links file://{} {}\n'
                                .format(dockerfile_cmd, dir_pip_packages,
                                        package))
                    for d in uninstall_dependencies:
                        dest.write(
                            'RUN apt-get remove -y {}\n'.format(d))

                else:
                    dest.write(line)

if __name__ == '__main__':
    run()
