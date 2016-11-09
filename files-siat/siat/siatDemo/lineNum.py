#encoding:utf-8

f = open("E:/siat/Doc/data/ttdb2.txt","r")
print len(f.readlines())

# from string import *
# def countWords(s):
# 	words=split(s)
# 	return len(words)

# total_words=0
# for line in f:
# 	total_words=total_words + countWords(line)
# print total_words


# result = list()  
# for line in f:                        
#     line = line.strip()                               
#     result.append(line)                        
 
# print ' '.join(result)


open('E:/siat/Doc/data/Tdb2.txt', 'w').write(open('E:/siat/Doc/data/db12.txt','r').read().replace('\n',' '))


with open("E:/siat/Doc/data/Tdb2.txt","r") as fr:
	with open("E:/siat/Doc/data/Ldb2.txt","w") as fw:
		for line in fr.readlines():
			l = line.split(" ")
			print len(l)
			k = 0
			for i in range(len(l)):
				if (i+1)%3600 ==0 :
					fw.write(" ".join(l[k:k+3600]))
					fw.write("\r\n")
					k = k + 3600

f = open("E:/siat/Doc/data/Ldb2.txt","r")
print len(f.readlines())