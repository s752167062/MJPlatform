
import os
import os.path
import cocos
from shutil import copy2
 
def copy_file(src, dst):
    names = os.listdir(src)
    for name in names:
        if name.startswith('.'):#ignore all the file or dir start width '.' ,like .svn .D
            continue
        srcname = os.path.join(src, name)
        dstname = os.path.join(dst, name)
        try:
            copy2(srcname, dstname)
        except (IOError, os.error) as why:
            errors.append((srcname, dstname, str(why)))
 
def handle_event(event, target_platform, args):
    if target_platform != "android":
        return
    # cocos.Logging.info(event)
    if event != "pre-copy-assets":
        return
    # cocos.Logging.info("args is %s\n" % args)
    src = os.path.join(args["platform-project-path"], "prebuild", "libs", "armeabi")
    dst = os.path.join(args["platform-project-path"], "libs", "armeabi")
    # copy so
    copy_file(src, dst)

    # cocos.Logging.info("args is %s\n" % args)
    src = os.path.join(args["platform-project-path"], "prebuild", "libs", "armeabi-v7a")
    dst = os.path.join(args["platform-project-path"], "libs", "armeabi-v7a")
    # copy so
    copy_file(src, dst)

    # cocos.Logging.info("args is %s\n" % args)
    src = os.path.join(args["platform-project-path"], "prebuild", "assets")
    dst = os.path.join(args["platform-project-path"], "assets")
    # copy so
    copy_file(src, dst)


