# Integração do campo opcional `dataRetirada` em Agendamentos

Este documento orienta a equipe de frontend sobre como integrar o novo campo opcional `dataRetirada` nos agendamentos. Esse campo registra a data/hora de retirada de material (por exemplo, exame de fezes) e é independente da `dataHora` do agendamento.

## Visão geral

- Backend adicionou `dataRetirada?: Date` na entidade `Appointment` (nullable).
- Endpoints `POST /appointments` e `PATCH /appointments/:id` aceitam e retornam `dataRetirada` como string ISO ou `null`.
- Não há checagem de conflito/horário para `dataRetirada`; as regras de conflito continuam válidas para `dataHora` e `examTypeId`.

## Endpoints e payloads

### Criar agendamento

`POST /appointments`

Body (exemplo):

```json
{
  "pacienteId": "<uuid-paciente>",
  "examTypeId": "<uuid-exam-type>",
  "dataHora": "2025-11-20T14:30:00Z",
  "dataRetirada": "2025-11-19T09:00:00Z",
  "observacoes": "Retirar kit um dia antes"
}
```

Observações:
- `dataRetirada` é opcional; omitir se não houver retirada.
- As datas devem ser enviadas como ISO (preferência UTC). 

### Editar agendamento

`PATCH /appointments/:id`

- Definir/alterar retirada:

```json
{
  "dataRetirada": "2025-11-22T08:00:00Z"
}
```

- Remover retirada:

```json
{
  "dataRetirada": null
}
```

Observações:
- `examTypeId` também pode ser atualizado; conflitos seguem regras existentes.
- `observacoes` e `status` permanecem suportados.

## Integração no Flutter (API-5-FRONT)

### Modelos

- Atualizar `AppointmentModel` para incluir `DateTime? dataRetirada`.
- `fromJson`:
  - Ler `json['dataRetirada']` e usar `DateTime.tryParse(...)` quando presente.
- `toJson`:
  - Incluir `"dataRetirada": dataRetirada?.toUtc().toIso8601String()` quando definido.
  - Não incluir a chave quando `dataRetirada == null` (para criação sem retirada).

### Create vs Update

- Create: `appointment_service.createAppointment` já usa `model.toJson()`; após adicionar o campo ao modelo, o valor será enviado automaticamente quando definido.
- Update: `appointment_service.updateAppointment` aceita mapa de `fields`. Para remoção explícita, enviar `{"dataRetirada": null}`. Para definir, enviar `{"dataRetirada": "<ISO>"}`.

### UI/Formulário

- Campo opcional adicionado: Date/Time picker com rótulo "Data de Retirada (opcional)".
- Persistência no `AppointmentModel` via `withdrawalDate` e envio no `toJson()`.
- Botão "Remover retirada" disponível; no submit envia `{"dataRetirada": null}` para limpar.
- Listagem atualiza o subtítulo para incluir "Retirada: dd/MM/yyyy HH:mm" quando presente.

### Serialização e fuso horário

- Use `toUtc().toIso8601String()` para consistência.
- Na UI, exibir no fuso local do usuário se aplicável.

## Integração no SPA Web (API-5-WEB) [se aplicável]

- Tipos TS: `dataRetirada?: string | null`.
- Create: incluir `dataRetirada` como ISO opcional.
- Update: enviar `dataRetirada: null` para limpar ou ISO para definir.

## Comportamento do backend

- Valida `dataRetirada` (formato de data), rejeita strings inválidas.
- `null` limpa o campo na base (coluna `nullable`).
- Não há validações de conflito para `dataRetirada`.

## Checklist de integração

- [ ] Atualizar `AppointmentModel` com `dataRetirada` (opcional) e ajustar `toJson/fromJson`.
- [ ] Adicionar campo no formulário de agendamento (opcional, com limpar).
- [ ] Ajustar `updateAppointment` para enviar `dataRetirada: null` ao limpar.
- [ ] Exibir `dataRetirada` nas telas de detalhe/lista quando existir.
- [ ] Validar manualmente criação, edição, remoção e exibição.

## Testes manuais sugeridos

1. Criar agendamento sem `dataRetirada`; salvar e verificar resposta e listagem.
2. Editar e definir `dataRetirada`; salvar e verificar retorno e UI.
3. Remover `dataRetirada` enviando `null`; confirmar remoção na UI e API.
4. Tentar enviar `dataRetirada` com formato inválido; esperar erro de validação.

## Observações finais

- Se desejarem validar `dataRetirada` dentro do horário de funcionamento, podemos implementar checagem similar à de `dataHora`.
- O PDF/relatórios não exibem `dataRetirada` por padrão; podemos incluir se necessário.