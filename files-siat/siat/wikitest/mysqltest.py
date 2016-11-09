#ecoding:utf-8
import json
import mysql.connector
import collections

def getData():
	conn = mysql.connector.connect(user="root",password="",database="wikidatatest")
	cursor = conn.cursor()

	cursor = conn.cursor()
	cursor.execute('''select time,value from edata_edata''')
	values = cursor.fetchall()
	rowarray_list = []
	for row in values:
		d = collections.OrderedDict()
		d['label'] = row[0]
		d['value'] = row[1]
		rowarray_list.append(d)
	
	j = json.dumps(rowarray_list)
	return rowarray_list
	
	