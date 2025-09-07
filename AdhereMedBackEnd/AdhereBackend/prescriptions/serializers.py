from rest_framework import serializers
from .models import Medication, PatientLog, PrescribedMedication, Prescription, Checkup, Consultation


class PrescribedMedicationSerializer(serializers.ModelSerializer):
    class Meta:
        model = PrescribedMedication
        fields = ['id', 'prescription', 'medication', 'dosage', 'instructions', 'morning', 'afternoon', 'evening', 'duration', "start_date"]

    def create(self, validated_data):
        prescribedMeds = PrescribedMedication.objects.create(**validated_data)

        return prescribedMeds
    

class PrescriptionSerializer(serializers.ModelSerializer):
    prescribed_medications = PrescribedMedicationSerializer(many=True, read_only=True, source='prescribedmedication_set')

    class Meta:
        model = Prescription
        fields = "__all__"
        read_only_fields = ['id', 'created_at']

    def create(self, validated_data):
        # Extract the authenticated doctor from the request
        doctor = self.context['request'].user.doctor
        # Assign the doctor to the prescription
        validated_data['doctor'] = doctor
        # Create the prescription
        prescription = Prescription.objects.create(**validated_data)
        return prescription
    
class MedicaionSerializer(serializers.ModelSerializer):
    class Meta:
        model = Medication
        fields = ['id', 'name', 'instructions', 'images']

    def create(self, validated_data):
        medication = Medication.objects.create(**validated_data)
        return medication
    
class PatientLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = PatientLog
        fields = ['id', 'feeling', 'symptoms', 'timestamp']

class ConsultationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Consultation
        fields = '__all__'
        
class CheckupSerializer(serializers.ModelSerializer):
    class Meta:
        model = Checkup
        fields = ['symptoms', 'date', 'id', 'user', 'status']
