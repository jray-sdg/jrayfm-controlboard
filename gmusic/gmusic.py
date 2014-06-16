#!/bin/python

from __future__ import print_function
from __future__ import division
from random import random
from random import randrange
from random import choice
from datetime import datetime
from gmusicapi import Mobileclient

api = Mobileclient()
loggedin = api.login('lol', 'nope')

if loggedin != True:
    print('Not logged in')

songs = api.get_all_songs()
playlists = api.get_all_user_playlist_contents()

songPool = {}
bumpersPool = []
signoffPool = []

for s in songs:
    songPool[s['id']] = s['artist']
    if s['comment'].find('JRay-FM Bumper') != -1:
        bumpersPool.append(s['id'])
    elif s['comment'].find('JRay-FM Sign-off') != -1:
        signoffPool.append(s['id'])
		
print('Songs: ' + str(len(songPool)))
print('Bumpers: ' + str(len(bumpersPool)))
print('Sign-off: ' + str(len(signoffPool)))

playlistPool = {}
        
for p in playlists:
    if p['name'] == 'JRayFM-Library':
        for t in p['tracks']:
            if songPool[t['trackId']] in playlistPool:
                playlistPool[songPool[t['trackId']]].append(t['trackId'])
            else:
                playlistPool[songPool[t['trackId']]] = [ t['trackId'] ]

print('Library: ' + str(len(playlistPool)))
for (k,v) in playlistPool.iteritems():
    print('{' + k + '} ' + str(len(v)))
				
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
        
newPlaylist = api.create_playlist('JRay-FM ' + datetime.now().strftime('%m/%d/%Y %H:%M:%S'))
localBumperPool = []
segmentCount = 0

for i in mergedPlaylist:
    api.add_songs_to_playlist(newPlaylist, i)
    segmentCount += 1
    if segmentCount > 3:
        segmentCount = 0
        if len(localBumperPool) == 0:
            localBumperPool = bumpersPool[:]
        selected = choice(localBumperPool)
        api.add_songs_to_playlist(newPlaylist, selected)
        localBumperPool.remove(selected)
    
api.add_songs_to_playlist(newPlaylist, choice(signoffPool))