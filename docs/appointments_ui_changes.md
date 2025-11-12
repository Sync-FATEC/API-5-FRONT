# Alterações na UI de Agendamentos

Este documento descreve as correções e melhorias aplicadas aos agendamentos.

## Correções de Layout (Overflow)
- Título e subtítulo do `CustomCard` passam a ter truncamento com reticências.
- `title` agora tem `maxLines: 1`; `subtitle` tem `maxLines: 2`.
- Evita estouro horizontal em resoluções menores mantendo legibilidade.

## Status visível no card
- Adicionado chip de status no canto superior direito do card.
- Cores por status:
  - Pendente: `AppColors.orange`
  - Confirmado: `AppColors.greenPrimary`
  - Cancelado: `AppColors.red`
- Helper reutilizável em `AppointmentUIHelpers` para rótulos e cores.

## Busca nos selects
- Substituição dos `DropdownButtonFormField` por `Autocomplete` para Paciente e Tipo de Exame.
- Busca parcial e case-insensitive (contains) via `StringUtils.filterByQuery`.
- Listas ordenadas alfabeticamente.
- Validação mantida: verificação explícita de seleção no `Salvar`.

## Formatação
- Datas nos cards formatadas como `dd/MM/yyyy HH:mm` via `intl`.

## Acessibilidade e UX
- Tooltips nos botões de ação do card.
- Mensagens de erro via `SnackBar` em validações.

## Arquivos modificados/adicionados
- `lib/ui/widgets/custom_card.dart`: truncamento e overflow.
- `lib/ui/views/appointments/appointments_screen.dart`: chip de status, data formatada, trailing responsivo.
- `lib/ui/views/appointments/widgets/appointment_form_modal.dart`: Autocomplete para selects.
- `lib/ui/views/appointments/widgets/appointment_ui_helpers.dart`: helpers de status.
- `lib/core/utils/string_utils.dart`: utilitário de busca.
- `test/string_utils_test.dart`: testes de busca.
- `test/appointment_ui_helpers_test.dart`: testes de mapeamento de status.

## Como validar
1. Abra a tela de agendamentos e verifique os chips de status.
2. Tente com nomes longos e confirme ausência de overflows.
3. No modal, pesquise por paciente/exame digitando parte do nome, em qualquer caixa.
4. Execute os testes: `flutter test`.

