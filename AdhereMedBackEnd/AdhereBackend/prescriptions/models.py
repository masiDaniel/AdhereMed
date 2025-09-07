from django.utils import timezone
from django.db import models
from accounts.models import CustomUser, Doctor, Patient

class Medication(models.Model):
    name = models.CharField(max_length=50)
    instructions = models.TextField()
    images = models.ImageField(upload_to='medication_images/', blank=True, null=True)

    def image_count(self):
        return self.medication_images.count()

    @property
    def can_add_image(self):
        return self.image_count() < 6

    def __str__(self):
        return self.name

class Prescription(models.Model):
    doctor = models.ForeignKey(Doctor, on_delete=models.CASCADE)
    patient = models.ForeignKey(Patient, on_delete=models.CASCADE)
    instructions = models.TextField()
    diagnosis = models.TextField(null=True, default='Adhere')
    created_at = models.DateTimeField(auto_now_add=True)
    # created_at_date = models.DateField()

    class Meta:
        constraints = [
            # models.UniqueConstraint(fields=['doctor', 'patient'], name='unique_prescription_per_doctor_and_medication')
        ]

    def __str__(self):
        return f"Prescription from (Dr) { self.doctor.user.first_name} to (Ptn) {self.patient.user.first_name} created at {self.created_at}"

class PrescribedMedication(models.Model):
    prescription = models.ForeignKey(Prescription, on_delete=models.CASCADE)
    medication = models.ForeignKey(Medication, on_delete=models.CASCADE)
    dosage = models.CharField(max_length=50)
    instructions = models.TextField()
    morning = models.BooleanField(null=True, default=False)
    afternoon = models.BooleanField(null=True, default=False)
    evening = models.BooleanField(null=True, default=False)
    duration = models.IntegerField()
    start_date = models.DateField(default=timezone.now)

    class Meta:
        unique_together = ()

    def __str__(self):
        return f"{self.medication.name} for Prescription from (Dr) {self.prescription.doctor.user.first_name} to (Ptn) {self.prescription.patient.user.first_name}"

class PatientLog(models.Model):
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name="logs")
    feeling = models.CharField(max_length=100)  # Short description (e.g., "Feeling tired")
    symptoms = models.TextField()  # Detailed description of symptoms
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user.username} - {self.feeling} on {self.timestamp}"

class Checkup(models.Model):
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name="checkups")
    symptoms = models.TextField()
    date = models.DateField(auto_now_add=True)
    status = models.CharField(max_length=20, choices=[('pending', 'Pending'), ('confirmed', 'Confirmed')], default='pending')

    def __str__(self):
        return f"Checkup by {self.user.username} on {self.date}"
class Consultation(models.Model):
    user = models.ForeignKey(CustomUser, on_delete=models.CASCADE, related_name="consultations")
    doctor = models.ForeignKey(Doctor, on_delete=models.CASCADE, related_name="doctor_consultations")
    date_time = models.DateTimeField()
    status = models.CharField(max_length=20, choices=[('pending', 'Pending'), ('confirmed', 'Confirmed')])

    def __str__(self):
        return f"Consultation with {self.doctor} on {self.date_time}"
