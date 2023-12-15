#This script can be used to identify duplicates in surname data following the approach Buonnano and Vanin (2017)
#Authors: Jonas Elis, Manuel Diaz Garcia
#Date: 2023/12/13
#Notes:
	#(1) See "surname_diversity_calculation.R" for details on index calculation.
	#(2) Please take note of authors who created packages used in this Python script.
    #(3) source: https://towardsdatascience.com/fuzzywuzzy-find-similar-strings-within-one-column-in-a-pandas-data-frame-99f6c2a0c212
	#(4) Example refers to use of a STATA data set, can easily be adapted to Excel, text data.
#Legend:
	#PATH = your file path
    #DATAFILE = your data file
	#SURNAME = data column that contains surname on which index calculation is based
	#GEOUNIT = data column identifying geographical unit

#Import packages
import pandas as pd
import os
from fuzzywuzzy import process, fuzz

#Change path
os.chdir('PATH')

#Import data
names = pd.read_stata('DATAFILE')
names.head()
names.info()

#Only keep first section of double-barrelled surnames
names['SURNAME_split'] = names['SURNAME'].str.split('-').str[0]

#Delete whitespace within names, convert to lowercase, strip double barrel names and count unique values
for col in names[['SURNAME_split']]:
    names['SURNAME_split'] = names['SURNAME_split'].str.strip('\w')
    names['SURNAME_split'] = names['SURNAME_split'].str.lower()
    print('Unique values in ' + str(col) +': ' + str(names[col].nunique()))

#Check for unique names
unique_names = names['SURNAME'].unique().tolist()
sorted(unique_names)[:20]

#Take random sample to prepare for high computation time (optional)
names = names.sample(n=100,replace=True)

#Let fuzzywuzzy create string similarity table
score_sort = [(x,) + i
             for x in names['SURNAME_split'] 
             for i in process.extract(x,names['SURNAME_split'], scorer=fuzz.token_sort_ratio)]

similarity_sort = pd.DataFrame(score_sort, columns=['SURNAME_split','SURNAME_split','match_sort', 'GEOUNIT'])
similarity_sort.head(25)

#Dependeing on your preferences, you can now clean the data set and apply a threshold of similarity to correct the diversity index.