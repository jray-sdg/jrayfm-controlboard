#!/bin/python

from __future__ import print_function
from __future__ import division
from random import random
from random import randrange
from random import choice
from datetime import datetime
from gmusicapi import Mobileclient
from sys import exit

api = Mobileclient()
loggedin = api.login('lol', 'nope')

if loggedin != True:
    print('Not logged in')
    exit()

print('Retrieving song library... ', end='')

songs = api.get_all_songs()

print(str(len(songs)), 'songs')
print('Scanning for relevant tracks... ', end='')

bumpersPool = []
signoffPool = []
playlistPool = {}
thumbsCount = 0

for s in songs:
    if s['rating'] == '5':
        thumbsCount+=1
        if s['artist'] in playlistPool:
            playlistPool[s['artist']].append(s['id'])
        else:
            playlistPool[s['artist']] = [ s['id'] ]
    elif s['comment'].find('JRay-FM Bumper') != -1:
        bumpersPool.append(s['id'])
    elif s['comment'].find('JRay-FM Sign-off') != -1:
        signoffPool.append(s['id'])

print(str(thumbsCount), 'thumbs,', str(len(bumpersPool)), 'bumpers,', str(len(signoffPool)), 'signoffs')
print('Building playlist... ', end='')
				
longestPool = 0

for p in playlistPool.itervalues():
    if len(p) > longestPool:
        longestPool = len(p)
        
filledPlaylist = {}

for (k,v) in playlistPool.iteritems():
    filledPlaylist[k] = []
    ones = len(v)
    invert = False
    if ones > longestPool / 2:
        ones = longestPool - ones
        invert = True
    bitmap = [False for x in range(longestPool)]
    remaining = longestPool
    for x in reversed(range(ones)):
        bitmap[int(longestPool - remaining)] = True
        skip = remaining / (x + 1)
        skip = (0.9 * skip) + (random() * ((1.1 * skip) - ((0.9 * skip) + 2)))
        remaining -= min(max(1, skip), remaining - x + 2)
    if invert == True:
        bitmap = [not b for b in bitmap]
    offset = randrange(longestPool)
    localPool = v[:]
    pointer = offset
    while True:
        if bitmap[pointer] == True:
            selected = choice(localPool)
            filledPlaylist[k].append(selected)
            localPool.remove(selected)
        else:
            filledPlaylist[k].append('')
        pointer += 1
        if pointer > longestPool - 1:
            pointer = 0
        if pointer == offset:
            break

mergedPlaylist = []
            
for x in range(longestPool):
    tempList = []
    for k in filledPlaylist.iterkeys():
        if filledPlaylist[k][x] != '':
            tempList.append(filledPlaylist[k][x])
    while len(tempList) > 0:
        selected = choice(tempList)
        mergedPlaylist.append(selected)
        tempList.remove(selected)

print('done')
print('Saving playlist... ', end='')

finalPlaylist = []
localBumperPool = []
segmentCount = 0

for i in mergedPlaylist:
    finalPlaylist.append(i)
    segmentCount += 1
    if segmentCount > 3:
        segmentCount = 0
        if len(localBumperPool) == 0:
            localBumperPool = bumpersPool[:]
        selected = choice(localBumperPool)
        finalPlaylist.append(selected)
        localBumperPool.remove(selected)
    
finalPlaylist.append(choice(signoffPool))

newPlaylist = api.create_playlist('JRay-FM ' + datetime.now().strftime('%m/%d/%Y %H:%M:%S'))
api.add_songs_to_playlist(newPlaylist, finalPlaylist)
api.logout()

print('done')