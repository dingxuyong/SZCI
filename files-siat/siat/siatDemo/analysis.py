#ecoding:utf-8
import mysql.connector
import collections

conn = mysql.connector.connect(user="root",password="",database="mytest")
cursor = conn.cursor()

cursor = conn.cursor()
cursor.execute('''select * from ecg''')
values = cursor.fetchall()
# testvalues = values[:1000]
length = len(values)
# for i in testvalues:
# 	print i

j = 0
m = 10.20 
array_list=[]

for i in xrange(length):	
	if values[i][1] > 0.38 and values[i][0] > m:
		j = j + 1
		m = m + 0.78
		array_list.append(values[i][0])
		print values[i][0],

print
print j

sub_list = []

for i in xrange(len(array_list)-1):
	sub = array_list[i + 1] - array_list[i]
	sub_list.append(sub)

for i in sub_list:
	print i,

print

for i in xrange(len(sub_list) - 1):
	if sub_list[i] < 0.7 and sub_list[i + 1] > 0.85:
		print 'it\'s early jump,belong to ',
		print  i+1
