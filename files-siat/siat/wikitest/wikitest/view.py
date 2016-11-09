#from django.http import HttpResponse
import json
from django.shortcuts import render
from mysqltest import getData

def regester(request):
	return render(request,"regester.html")

def index(request):
	msg = 'Log In First'
	return render(request,"index.html",{'messages':msg,})

def health(request):
	datas = getData()
	return render(request,'health.html',{'datas':json.dumps(datas),})


def diagnosis(request):
	suggests = "keap health!!!"
	return render(request,'base.html',{'messages':suggests,})

def history(request):
	diadata = "2016-1-1"
	return render(request,"base.html",{'messages':diadata,})

def message(request):
	name = "patient"
	return render(request,"base.html",{'messages':name,})