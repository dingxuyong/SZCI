from __future__ import unicode_literals

from django.db import models

class Edata(models.Model):
	time = models.FloatField()
	value = models.FloatField()



