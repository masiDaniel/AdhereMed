from django.urls import path
from .views import  DoctorListView, LogOutApIView, RegisterUsersAPIView, LoginApIView

urlpatterns = [
    path("doctorsignup/", RegisterUsersAPIView.as_view(), name="doctorsignup"),
    path("patientsignup/", RegisterUsersAPIView.as_view(), name="patientsignup"),
    path("doctorlogin/", LoginApIView.as_view(), name="doctorlogin"),
    path("patientlogin/", LoginApIView.as_view(), name="patientlogin"),
    path("logout/", LogOutApIView.as_view(), name="logout"),
    path('doctors/', DoctorListView.as_view(), name='doctor-list'),

]