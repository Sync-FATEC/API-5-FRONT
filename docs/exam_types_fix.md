# Correção de falhas na criação/edição de Tipos de Exame

## Causa raiz provável

- O modal de criação/edição (`ExamTypeFormModal`) podia não acessar corretamente o `ExamTypesViewModel` em alguns cenários de `showDialog`, levando a erros de Provider não encontrado durante a submissão.
- O fluxo de edição enviava o `toJson()` completo (incluindo `id`/`isActive`) no PATCH, em vez de apenas campos alteráveis; isso podia causar comportamento inesperado no backend.
- Ausência de guardas para `id` nulo/empty ao editar podia gerar exceções.

## Principais correções

- O modal agora injeta o `ExamTypesViewModel` explicitamente via `ChangeNotifierProvider.value` dentro do `showDialog`, garantindo acesso estável.
- Sanitização do payload de atualização: apenas `nome`, `descricao`, `duracaoEstimada`, `preparoNecessario` são enviados.
- Guarda para `id` inválido no fluxo de edição, com feedback ao usuário via `SnackBar`.
- Estado de submissão (`_isSubmitting`) para evitar cliques múltiplos e fornecer feedback visual (“Salvando…”).
- Verificação de `id` vazia no `ExamTypesViewModel.update` com mensagem de erro clara.

## Componentes verificados

- Validação: nome obrigatório; duração inteira > 0 e <= 480.
- Comunicação com API: contratos revisados com o backend (`/exam-types`), mapeamentos mantidos.
- Atualização de estado: `ChangeNotifier` notifica corretamente em sucesso/erro; lista é atualizada.
- Tratamento de erros: exceções capturadas; mensagens exibidas via `SnackBar`.

## Testes adicionados

- Unit: `ExamTypesViewModel` (sucesso em criação/edição; falhas de validação e ID vazio).
- Widget: validação do formulário bloqueando duração inválida e exibindo mensagem.

## Arquivos alterados

- `ui/views/exam_types/widgets/exam_type_form_modal.dart`
- `ui/viewmodels/exam_types_viewmodel.dart`
- `test/exam_types_viewmodel_test.dart`
- `test/exam_type_form_modal_test.dart`

## Observações

- O backend ignora `isActive` no update; manter envio apenas de campos alteráveis evita ambiguidade.
- A lista de exam types não possui filtros no backend no momento; chamadas com `q`/`isActive` permanecem compatíveis mas podem não filtrar no servidor.