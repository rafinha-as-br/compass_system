import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/account/domain/entities/agent_profile.dart';
import 'package:travel_matrix/features/account/presentation/view_models/agent_profile_view_model.dart';

void main() {
  group('AgentProfileViewModel', () {
    const profile = AgentProfile(
      id: '1',
      name: 'Agent Smith',
      email: 'agent@matrix.com',
      cpf: '000.000.000-00',
      cnpj: '00.000.000/0000-00',
      phoneNumber: '11999999999',
    );

    test('fromDomain round-trips every field without loss', () {
      final viewModel = AgentProfileViewModel.fromDomain(profile);

      expect(viewModel.id, profile.id);
      expect(viewModel.name, profile.name);
      expect(viewModel.email, profile.email);
      expect(viewModel.cpf, profile.cpf);
      expect(viewModel.cnpj, profile.cnpj);
      expect(viewModel.phoneNumber, profile.phoneNumber);
    });

    group('initials', () {
      test('uses first letters of first and last name', () {
        final viewModel = AgentProfileViewModel.fromDomain(profile);

        expect(viewModel.initials, 'AS');
      });

      test('uses a single letter for a single-word name', () {
        final viewModel =
            AgentProfileViewModel.fromDomain(profile.copyWithName('Neo'));

        expect(viewModel.initials, 'N');
      });

      test('falls back to "?" for an empty name', () {
        final viewModel =
            AgentProfileViewModel.fromDomain(profile.copyWithName('   '));

        expect(viewModel.initials, '?');
      });
    });
  });
}

extension _AgentProfileTestX on AgentProfile {
  AgentProfile copyWithName(String newName) {
    return AgentProfile(
      id: id,
      name: newName,
      email: email,
      cpf: cpf,
      cnpj: cnpj,
      phoneNumber: phoneNumber,
    );
  }
}
