import 'package:flutter/material.dart';
import 'widgets/characters_app_bar.dart';
import 'widgets/characters_body.dart';
import 'widgets/characters_floating_button.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../controllers/characters_view_model.dart';
import '../../../widgets/app_drawer.dart';

/// Página de listagem de personagens
class CharactersView extends StatefulWidget {
  const CharactersView({super.key});

  @override
  State<CharactersView> createState() => _CharactersViewState();
}

class _CharactersViewState extends State<CharactersView> {
  late final CharactersViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = injector.get<CharactersViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.commands.fetchCharacters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CharactersAppBar(state: _viewModel.charactersState),
      drawer: AppDrawer(),
      body: CharactersBody(viewModel: _viewModel),
      floatingActionButton: CharactersFab(viewModel: _viewModel),
    );
  }
}

