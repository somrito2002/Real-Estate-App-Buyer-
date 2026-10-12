import 'package:flutter_test/flutter_test.dart';
import 'package:realty_app/models/property_model.dart';
import 'package:realty_app/services/partner_api_service.dart';

void main() {
  group('Partner and Public Profile Tests', () {
    test('Partner model safely parses profileViews and partnerType', () {
      final json = {
        'id': 'partner-123',
        'fullName': 'John Doe',
        'companyName': 'Skyline Developers',
        'partnerType': 'Builder / Developer',
        'profilePicture': '/Upload/partner/profile.jpg',
        'profileViews': 42,
      };

      final partner = Partner.fromJson(json);

      expect(partner.id, 'partner-123');
      expect(partner.fullName, 'John Doe');
      expect(partner.companyName, 'Skyline Developers');
      expect(partner.partnerType, 'Builder / Developer');
      expect(partner.profilePicture, 'https://api.prodalal.com/Upload/partner/profile.jpg');
      expect(partner.profileViews, 42);
    });

    test('PartnerPublicProfile correctly parses partner and properties array', () {
      final payload = {
        'partner': {
          'id': 'partner-uuid',
          'fullName': 'John Doe',
          'companyName': 'Skyline Developers',
          'partnerType': 'Builder / Developer',
          'profilePicture': '/Upload/partner/profile.jpg',
          'profileViews': 42,
        },
        'properties': [
          {
            'id': 'property-uuid',
            'title': 'Luxury 3BHK Apartment',
            'expectedPrice': '8500000',
            'images': ['/Upload/Property/img1.png'],
          }
        ],
      };

      final profile = PartnerPublicProfile.fromJson(payload);

      expect(profile.partner.id, 'partner-uuid');
      expect(profile.partner.fullName, 'John Doe');
      expect(profile.partner.profileViews, 42);
      expect(profile.partner.partnerType, 'Builder / Developer');

      expect(profile.properties.length, 1);
      expect(profile.properties.first.id, 'property-uuid');
      expect(profile.properties.first.title, 'Luxury 3BHK Apartment');
      expect(profile.properties.first.imageUrl, 'https://api.prodalal.com/Upload/Property/img1.png');
    });

    test('Property resolves partner name correctly from contactName or partner', () {
      final prop1 = Property.fromJson({
        'id': 'p1',
        'partnerId': 'c69bf08e-2539-47c8-8500-7a400cc66106',
        'contactName': 'Subhadip Mandal',
        'title': '10 Acres Land',
        'price': '50000000',
      });
      expect(prop1.partnerName, 'Subhadip Mandal');

      final prop2 = Property.fromJson({
        'id': 'p2',
        'partnerId': '1a3a48b0-273e-4b1f-a734-86894065cd8a',
        'contactName': 'Partner',
        'title': 'Et in ullamco quod v',
        'price': '790000',
      });
      expect(prop2.partnerName, 'Somrito');
    });

    test('Live API call test for PartnerApiService', () async {
      final profile = await PartnerApiService.getPublicProfile('c69bf08e-2539-47c8-8500-7a400cc66106');
      expect(profile.partner.id, 'c69bf08e-2539-47c8-8500-7a400cc66106');
      expect(profile.partner.fullName, isNotEmpty);
      expect(profile.partner.profileViews, isNonNegative);
      expect(profile.properties, isA<List<Property>>());
    });
  });
}
