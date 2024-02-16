from django.urls import path

from . import views

app_name = 'nova'

urlpatterns = [
    path('', views.index, name='index'),

]
