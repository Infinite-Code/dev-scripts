import glob


def run():
    keyword_req = ' INJECT_FROM_REQUIREMENTS:'
    for filename_template in glob.glob('Dockerfile-template.*'):
        print('Processing: {}'.format(filename_template))
        filename_dockerfile = filename_template.replace('-template', '')
        with open(filename_template, 'r') as src, \
                open(filename_dockerfile, 'w') as dest:
            for line in src:
                if keyword_req in line:
                    dockerfile_cmd, filename_req = map(lambda x: x.strip(),
                                                       line.split(keyword_req))
                    with open(filename_req, 'r') as req:
                        for package in req:
                            dest.write('{} {}'.format(dockerfile_cmd, package))
                else:
                    dest.write(line)

if __name__ == '__main__':
    run()
