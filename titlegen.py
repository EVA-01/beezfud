#!/usr/bin/env python
"""
# enable debugging
import cgitb
cgitb.enable()
print "Content-Type: text/plain;charset=utf-8"
"""
# Based on https://github.com/FiloSottile/HNTitles -> hngen.py
# -*- coding: ISO-8859-1 -*-

from collections import defaultdict
from random import random
import sys, getopt
from datetime import datetime
import math
import os
import codecs

#Typical sampling from a categorical distribution
def sample(items):
	next_word = None
	t = 0.0
	for k, v in items:
		t += v
		if t and random() < v/t:
			next_word = k
	return next_word

def get_sentence(markov_map, lookback, titles, length_max):
	while True:
		sentence = []
		next_word = sample(markov_map[''].items())
		while next_word != '':
			sentence.append(next_word)
			next_word = sample(markov_map[' '.join(sentence[-lookback:])].items())
		sentence = ' '.join(sentence)
		if any(sentence in title for title in titles):
			continue #Prune titles that are substrings of actual titles
		if len(sentence) > length_max:
			continue
		return sentence

def main(argv):
	lookback = 3
	length_max = 140
	mrange = 6
	latest = {
		"month": datetime.now().month,
		"year": datetime.now().year
	}
	earliest = {}
	se = datetime.now().month - mrange
	if se % 12 == 0:
		earliest["month"] = 12
		earliest["year"] = int(datetime.now().year - math.floor(se / 12) - 1)
	else:
		earliest["month"] = se % 12
		earliest["year"] = int(datetime.now().year - math.floor(se / 12))
	error = False
	try:
		opts, args = getopt.getopt(argv, "l:m:e:c:r:", ["lookback=", "max=", "earliest=", "latest=", "range="])
	except getopt.GetoptError:
		error = True
	if not error:
		late = False
		earl = False
		rang = False
		for opt, arg in opts:
			if opt in ("-l", "--lookback"):
				lookback = int(arg)
			elif opt in ("-m", "--max"):
				length_max = int(arg)
			elif opt in ("-e", "--earliest"):
				earliest["month"] = int(arg.split(",")[0])
				earliest["year"] = int(arg.split(",")[1])
				earl = True
			elif opt in ("-c", "--latest"):
				latest["month"] = int(arg.split(",")[0])
				latest["year"] = int(arg.split(",")[1])
				late = True
			elif opt in ("-r", "--range"):
				mrange = int(arg)
				rang = True
		if late == True and earl == False or (late == False and earl == False and rang == True):
			earliest = {}
			se = latest["month"] - mrange
			if se % 12 == 0:
				earliest["month"] = 12
				earliest["year"] = int(latest["year"] + math.floor(se / 12) - 1)
			else:
				earliest["month"] = se % 12
				earliest["year"] = int(latest["year"] + math.floor(se / 12))
		elif late == False and earl == True:
			latest = {}
			se = earliest["month"] + mrange
			if se % 12 == 0:
				latest["month"] = 12
				latest["year"] = int(earliest["year"] + math.floor(se / 12) - 1)
			else:
				latest["month"] = se % 12
				latest["year"] = int(earliest["year"] + math.floor(se / 12))
	titles = []
	cyear = earliest["year"]
	while cyear <= latest["year"]:
		if os.path.isdir("archive/" + str(cyear)):
			if cyear == earliest["year"]:
				b = earliest["month"]
			else:
				b = 1
			if cyear == latest["year"]:
				e = latest["month"]
			else:
				e = 12
			while b <= e:
				if os.path.exists("archive/" + str(cyear) + "/" + str(b) + ".txt"):
					archive = codecs.open("archive/" + str(cyear) + "/" + str(b) + ".txt", encoding="utf-8")
					titles += archive.read().split("\n")
					archive.close()
				b += 1
		cyear += 1
	markov_map = defaultdict(lambda:defaultdict(int))
	#Generate map in the form word1 -> word2 -> occurences of word2 after word1
	for title in titles[:-1]:
		title = title.split()
		if len(title) > lookback:
			for i in range(len(title)+1):
				markov_map[' '.join(title[max(0,i-lookback):i])][' '.join(title[i:i+1])] += 1
	#Convert map to the word1 -> word2 -> probability of word2 after word1
	for word, following in markov_map.items():
		total = float(sum(following.values()))
		for key in following:
			following[key] /= total
	print(get_sentence(markov_map, lookback, titles, length_max))

if __name__ == "__main__":
	main(sys.argv[1:])