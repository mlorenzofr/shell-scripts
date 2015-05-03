#!/usr/bin/python
# -*- coding: utf-8 -*-

from getopt import getopt,GetoptError
from os.path import isfile
from re import search,split,I
from sys import argv,exit
from time import strptime,mktime,strftime,localtime

def usage():
    """
    Show the help message.
    """
    print "Usage: %s -f <file> -o <offset> [-s NUMBER] [-i]" % argv[0]
    print "Return a new srt file with times fixed"
    print "-f, --file <filename>\tInput file"
    print "-i, --inteligent\tTry to increase the offset in each pause"
    print "-o, --offset <secs>\tIncrease/Decrease N seconds"
    print "-s, --since <location>\tDo the changes since X subtitle"
    return

def getOffset(time, offset):
    """
    Return the time with offset fixed.

    Arguments:
     @time(str): time in format %H:%M:%S
     @offset(int): secs to increase/decrease
    """
    fixYear="2000 %s" % time
    flTime=strptime(fixYear, '%Y %H:%M:%S')
    newtime=mktime(flTime)+float(offset)
    return strftime('%H:%M:%S', localtime(newtime))

def fixTime(strTime, offset):
    """
    Return the line with subtitle times (begin & end) with the offset applied.
    
    Arguments:
     @strTime(str): complete line with times
     @offset(int): secs to increase/decrease
    """
    words = split(' ', strTime)
    begin = getOffset(words[0][0:8],offset)
    end = getOffset(words[2][0:8],offset)
    return "%s,%s --> %s,%s" % (begin, words[0].strip('\r\n')[-3:],
                                end, words[2].strip('\r\n')[-3:])

def main():
    patchSince = 1
    inputFile = ''
    intelligent = False
    offset = 0
    try:
        opts, args = getopt(argv[1:], 'f:io:s:',
                            ['file', 'inteligent', 'offset', 'since'])
    except GetoptError, descError:
        if search('not recognized', str(descError), I) != None:
            print 'Unknown option -%s' % descError[1]
        usage()
        exit(3)
    for opt, arg in opts:
        if opt in ['-f', '--file']:
            inputFile = arg
        if opt in ['-i', '--intelligent']:
            intelligent = True
        if opt in ['-o', '--offset']:
            offset = int(arg)
        if opt in ['-s', '--since']:
            patchSince = int(arg)
    if (inputFile == '') or (offset == 0):
        usage()
        exit(1)
    if not isfile(inputFile):
        print "%s file not found" % argv[1]
        exit(2)
    fileHandle = open(inputFile, 'r')
    dialogCounter = 1
    dialogBuffer = list()
    for line in fileHandle.readlines():
        if search('-->', line) == None:
            if search('^[0-9]+$', line.strip('\r\n')) == None:
                # print "%s" % line.strip('\n')
                if intelligent and (line.strip('\r\n') == '  ') \
                   and (dialogCounter > patchSince):
                    dialogBuffer[0] = fixTime(dialogBuffer[0],offset)
                dialogBuffer.append(line.strip('\r\n'))
            else:
                # print "%s" % dialogCounter
                dialogBuffer.append(str(dialogCounter))
                dialogCounter += 1
        else:
            print '%s' % '\n'.join(dialogBuffer)
            dialogBuffer = []
            if (dialogCounter > patchSince):
                dialogBuffer.append(fixTime(line, offset))
            else:
                # print "%s" % line.strip('\n')
                dialogBuffer.append(line.strip('\r\n'))
    print '%s' % '\n'.join(dialogBuffer)
    fileHandle.close()
    return

if __name__ == '__main__':
    main()
