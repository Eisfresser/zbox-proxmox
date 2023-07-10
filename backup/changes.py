# show changes between two rsync backups
# usage: ssh rsync@jabba "python" < files/changes.py


import os as os
from datetime import datetime
from filecmp import dircmp

import shutil


def get_size(start_path = '.', unit='Bytes'):
    '''Return total size of files in start_path'''
    total_size = 0
    for dirpath, dirnames, filenames in os.walk(start_path):
        for f in filenames:
            fp = os.path.join(dirpath, f)
            # skip if it is symbolic link
            if not os.path.islink(fp):
                total_size += os.path.getsize(fp)
    return total_size


def toMib(size):
    '''Convert size in bytes to MiB'''
    return size / (1024 * 1024)


def truncPathName(pathname, n=118):
    '''Truncate pathname to n characters'''
    if len(pathname) < n:
        return pathname
    else:
        return '...' + pathname[-n-3:]


def reportOnly(loc, path, only):
    '''Report files only in left or right'''
    for item in only:
        pathname = os.path.join(path, item)
        if os.path.isdir(pathname):
            print(f'{loc} {truncPathName(pathname)}/ {toMib(get_size(pathname)):0.3f} MiB')
        else:
            print(f'{loc} {truncPathName(pathname)} {toMib(os.path.getsize(pathname)):0.3f} MiB')


def dc(left, right):
    '''Compare two directories recursively.'''
    dcmp = dircmp(left, right)
    if len(dcmp.left_only) > 0: 
        reportOnly('deleted', left, dcmp.left_only)
    if len(dcmp.right_only) > 0:
        reportOnly('added', right, dcmp.right_only)
    if len(dcmp.diff_files) > 0:
        reportOnly('different', right, dcmp.diff_files)
    if len(dcmp.common_dirs) > 0:
        for common_dir in dcmp.common_dirs:
            dc(os.path.join(left, common_dir), os.path.join(right, common_dir))


def getLatestDirs(dir):
    '''Return the two latest directories in dir'''
    dirs = [os.path.join(dir, d) 
            for d in os.listdir(dir) 
                if os.path.isdir(os.path.join(dir, d))
                and d.startswith('20')]
    #dirs.sort(key=lambda x: os.path.getmtime(x))
    dirs.sort()
    return tuple(dirs[-2:])


def removeOlderDirs(path, days=10):
    '''Remove directories older than 10 days except when it's Monday'''
    now = datetime.now()
    for dir_name in os.listdir(path):
        if not dir_name.startswith('20'):
            continue
        dir_datetime = datetime.strptime(dir_name, "%Y-%m-%d_%H:%M:%S")  # Convert to datetime object
        if (now - dir_datetime).days > days and dir_datetime.weekday() != 0:
            print(f'removing {dir_name}')
            shutil.rmtree(os.path.join(path, dir_name))


root = '/volume1/rsync_dagobert/'
keepdays = 15

left, right = getLatestDirs(root)
start = datetime.now()
print('Changes start time: ', start)
print(f'Changes from {left} to {right}')
dc(left, right)
end = datetime.now()
print(f'Changes elapsed time: {end - start}')

start = datetime.now()
print(f'Removing backups older than {keepdays} days start time: ', start)
removeOlderDirs(root, keepdays)
end = datetime.now()
print(f'Removing elapsed time: {end - start}')
