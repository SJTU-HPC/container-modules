#!/usr/bin/env python3

import argparse
import configparser
import json
import logging
import os
import subprocess

logging.basicConfig(format='[%(levelname)s]\t: %(message)s',
                    level=logging.DEBUG)

software_name = [path for path in os.listdir() if os.path.isdir(path)]
software_name.remove('.git')


def update(config_path, name, tag, force):
    config = configparser.ConfigParser()
    config.read(config_path)
    logging.info("Read in config file.")
    for section in config.sections():
        tags = json.loads(config.get(section, "tag"))
        imgs = json.loads(config.get(section, "name"))
        url, path = config[section]["url"], config[section]["path"]
        if name != None and name != path:
            continue
        if tag != None and tag not in imgs:
            logging.error(f"Tag not available. {tag} not in {imgs}")
            exit(-1)
        for pull_tag, img_name in zip(tags, imgs):
            if tag != None and tag != img_name:
                continue
            if (not force) and os.path.exists(f"{path}/{img_name}.sif"):
                logging.info(
                    f"{path}/{img_name}.sif exsit. You can use `--force` to do a force update."
                )
                continue
            logging.info(
                f"Pull image from docker://{url}:{pull_tag} into {path}/{img_name}.sif."
            )
            pull_cmd = f"singularity pull --force {path}/{img_name}.sif docker://{url}:{pull_tag}"
            subprocess.call(pull_cmd, shell=True)


def main():
    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(dest='subparser')

    parser_update = subparsers.add_parser('update')
    parser_update.add_argument('-c',
                               '--config',
                               dest='config_path',
                               default='./config.ini')
    parser_update.add_argument('-n',
                               '--name',
                               dest='name',
                               choices=software_name)
    parser_update.add_argument('-t', '--tag', dest='tag')
    parser_update.add_argument('-f',
                               '--force',
                               dest='force',
                               action='store_true')

    kwargs = vars(parser.parse_args())
    if not kwargs['subparser']:
        parser.print_help()
        exit(-1)
    globals()[kwargs.pop('subparser')](**kwargs)


if __name__ == "__main__":
    main()
