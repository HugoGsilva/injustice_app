import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../domain/models/character_entity.dart';
import '../../../controllers/characters_view_model.dart';
import '../../../functions/ui_functions.dart';
import '../../../widgets/account_attribute_card.dart';
import '../../../widgets/app_drawer.dart';
import '../../../widgets/enum_dropdown_picker.dart';
import '../../../widgets/input_text_field.dart';
import 'character_form_fields_controller.dart';

class CharacterDetailView extends StatefulWidget {
  final Character? character;

  const CharacterDetailView({super.key, this.character});

  @override
  State<CharacterDetailView> createState() => _CharacterDetailViewState();
}

class _CharacterDetailViewState extends State<CharacterDetailView> {
  late final CharactersViewModel _viewModel;
  late final CharacterFormFieldsController _formFields;

  late final void Function() _disposeErrorEffect;

  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  // Form state
  late CharacterClass _characterClass;
  late CharacterRarity _rarity;
  late int _level;
  late int _threat;
  late int _attack;
  late int _health;
  late int _stars;
  late CharacterAlignment _alignment;

  bool get _isEditing => widget.character != null;

  @override
  void initState() {
    super.initState();
    _formFields = CharacterFormFieldsController();
    _viewModel = injector.get<CharactersViewModel>();

    if (_isEditing) {
      _preencherCampos(widget.character!);
    } else {
      _resetFields();
    }

    _disposeErrorEffect = effect(() {
      final errorMessage = _viewModel.charactersState.message.value;

      if (errorMessage != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          showSnackBar(context, errorMessage, backgroundColor: Colors.red);
          _viewModel.charactersState.clearMessage();
        });
      }
    });
  }

  void _preencherCampos(Character character) {
    _formFields.name.controller.text = character.name;
    _characterClass = character.characterClass;
    _rarity = character.rarity;
    _level = character.level;
    _threat = character.threat;
    _attack = character.attack;
    _health = character.health;
    _stars = character.stars;
    _alignment = character.alignment;
  }

  void _resetFields() {
    _formFields.name.controller.clear();
    _characterClass = CharacterClass.poderoso;
    _rarity = CharacterRarity.prata;
    _level = 1;
    _threat = 0;
    _attack = 0;
    _health = 0;
    _stars = 1;
    _alignment = CharacterAlignment.heroi;
  }

  @override
  void dispose() {
    _disposeErrorEffect();
    _scrollController.dispose();
    _formFields.dispose();
    super.dispose();
  }

  void _resetFormView() {
    FocusScope.of(context).unfocus();
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _focusFirstError() {
    for (final field in _formFields.fields) {
      final state = field.key.currentState;
      if (state != null && !state.isValid) {
        field.focus.requestFocus();
        Scrollable.ensureVisible(
          field.key.currentContext!,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        break;
      }
    }
  }

  bool _validateForm() {
    final valid = _formKey.currentState!.validate();
    if (!valid) {
      _focusFirstError();
    }
    return valid;
  }

  String? _validateNotEmpty(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }
    return null;
  }

  Future<void> _salvarPersonagem() async {
    if (!_validateForm()) return;

    final now = DateTime.now();
    final character = Character(
      id: widget.character?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _formFields.name.controller.text.trim(),
      characterClass: _characterClass,
      rarity: _rarity,
      level: _level,
      threat: _threat,
      attack: _attack,
      health: _health,
      stars: _stars,
      alignment: _alignment,
      createdAt: widget.character?.createdAt ?? now,
      updatedAt: now,
    );

    if (_isEditing) {
      await _viewModel.commands.updateCharacter(character);
    } else {
      await _viewModel.commands.addCharacter(character);
    }

    if (!mounted) return;

    _resetFormView();

    final message = _isEditing ? 'Personagem atualizado!' : 'Personagem criado!';
    showSnackBar(context, message, backgroundColor: Colors.green);

    // Pequeno delay para SnackBar aparecer antes de navegar
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.goNamed(AppRouteNames.characters);
    }
  }

  Future<void> _excluirPersonagem() async {
    if (widget.character == null) return;

    final confirm = await confirmDialog(
      context,
      title: 'Excluir Personagem',
      message: 'Tem certeza que deseja excluir ${widget.character!.name}?',
      confirmText: 'EXCLUIR',
    );

    if (!confirm) return;

    await _viewModel.commands.deleteCharacter(widget.character!.id);

    if (!mounted) return;

    showSnackBar(context, '${widget.character!.name} removido', backgroundColor: Colors.red);

    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.goNamed(AppRouteNames.characters);
    }
  }

  Widget _buildSaveButton() {
    return Watch((context) {
      final isRunning =
          _viewModel.commands.createCharacterCommand.isExecuting.value ||
              _viewModel.commands.updateCharacterCommand.isExecuting.value;

      return ElevatedButton(
        onPressed: isRunning ? null : _salvarPersonagem,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        child: isRunning
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                _isEditing ? 'SALVAR' : 'CRIAR',
                style: context.textStyles.titleMedium?.bold,
              ),
      );
    });
  }

  Widget _buildDeleteButton() {
    return Watch((context) {
      final isDeleting =
          _viewModel.commands.deleteCharacterCommand.isExecuting.value;

      return ElevatedButton(
        onPressed: isDeleting ? null : _excluirPersonagem,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          backgroundColor: Theme.of(context).colorScheme.tertiary,
        ),
        child: isDeleting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'EXCLUIR',
                style: context.textStyles.titleMedium?.bold,
              ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Personagem' : 'Novo Personagem'),
      ),
      drawer: AppDrawer(),
        body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmallScreen = constraints.maxWidth < 360;
            return SingleChildScrollView(
              controller: _scrollController,
              padding: isSmallScreen
                  ? AppSpacing.paddingMd
                  : AppSpacing.paddingLg,
              child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Nome
                InputTextField(
                  fieldKey: _formFields.name.key,
                  controller: _formFields.name.controller,
                  focusNode: _formFields.name.focus,
                  label: 'Nome',
                  hint: 'Digite o nome do personagem',
                  prefixIcon: Icons.person,
                  validator: _validateNotEmpty,
                ),
                const SizedBox(height: AppSpacing.md),

                // Classe
                EnumDropdownPicker<CharacterClass>(
                  label: 'Classe',
                  value: _characterClass,
                  values: CharacterClass.values,
                  displayNameBuilder: (v) => v.displayName,
                  onChanged: (v) => setState(() => _characterClass = v),
                ),
                const SizedBox(height: AppSpacing.md),

                // Raridade
                EnumDropdownPicker<CharacterRarity>(
                  label: 'Raridade',
                  value: _rarity,
                  values: CharacterRarity.values,
                  displayNameBuilder: (v) => v.displayName,
                  onChanged: (v) => setState(() => _rarity = v),
                ),
                const SizedBox(height: AppSpacing.md),

                // Alinhamento
                EnumDropdownPicker<CharacterAlignment>(
                  label: 'Alinhamento',
                  value: _alignment,
                  values: CharacterAlignment.values,
                  displayNameBuilder: (v) => v.displayName,
                  onChanged: (v) => setState(() => _alignment = v),
                ),
                const SizedBox(height: AppSpacing.md),

                // Level
                AccountAttributeCard(
                  icon: Icons.star,
                  iconColor: Theme.of(context).colorScheme.primary,
                  label: 'Level',
                  hint: '[1, 80]',
                  minValue: 1,
                  maxValue: 80,
                  value: _level,
                  onChanged: (v) => setState(() => _level = v),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Estrelas
                AccountAttributeCard(
                  icon: Icons.stars,
                  iconColor: Colors.amber,
                  label: 'Estrelas',
                  hint: '[1, 14]',
                  minValue: 1,
                  maxValue: 14,
                  value: _stars,
                  onChanged: (v) => setState(() => _stars = v),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Ameaça
                AccountAttributeCard(
                  icon: Icons.warning,
                  iconColor: Colors.orange,
                  label: 'Ameaça',
                  hint: 'Min: 0',
                  minValue: 0,
                  maxValue: 999999,
                  value: _threat,
                  onChanged: (v) => setState(() => _threat = v),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Ataque
                AccountAttributeCard(
                  icon: Icons.bolt,
                  iconColor: Colors.red,
                  label: 'Ataque',
                  hint: 'Min: 0',
                  minValue: 0,
                  maxValue: 999999,
                  value: _attack,
                  onChanged: (v) => setState(() => _attack = v),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Vida
                AccountAttributeCard(
                  icon: Icons.favorite,
                  iconColor: Colors.pink,
                  label: 'Vida',
                  hint: 'Min: 0',
                  minValue: 0,
                  maxValue: 999999,
                  value: _health,
                  onChanged: (v) => setState(() => _health = v),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Botões
                if (isSmallScreen)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSaveButton(),
                      if (_isEditing) ...[
                        const SizedBox(height: AppSpacing.md),
                        _buildDeleteButton(),
                      ],
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(child: _buildSaveButton()),
                      if (_isEditing) ...[
                        const SizedBox(width: AppSpacing.md),
                        Expanded(child: _buildDeleteButton()),
                      ],
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    ),
  ),
);
  }
}