from django.contrib import admin

from prescriptions.models import Medication, Prescription, PrescribedMedication, PatientLog, Consultation, Checkup

# Register your models here.
admin.site.register(Prescription)
admin.site.register(Medication)
admin.site.register(PrescribedMedication)
admin.site.register(PatientLog)
admin.site.register(Checkup)
admin.site.register(Consultation)