# Sistema de Controle de Estoque - Frontend

<div align="center">
  <h3>📦 Base Administrativa de Caçapava</h3>
  <p>Frontend do sistema de gerenciamento de estoque do almoxarifado e farmácia</p>

  ![React](https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB)
  ![TypeScript](https://img.shields.io/badge/TypeScript-007ACC?style=for-the-badge&logo=typescript&logoColor=white)
  ![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
  ![HTML5](https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&logo=html5&logoColor=white)
  ![CSS3](https://img.shields.io/badge/CSS3-1572B6?style=for-the-badge&logo=css3&logoColor=white)
</div>

# 🚦 Como Executar

## 📋 Pré-requisitos
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x)  
- [Node.js](https://nodejs.org/) (necessário apenas para versão web)  
- [Android Studio](https://developer.android.com/studio) ou [VSCode](https://code.visualstudio.com/) configurado  

## 📥 Instalação
Clone o repositório e instale as dependências:  
```bash
git clone https://github.com/Sync-FATEC/API-5-FRONT/
cd API-5-FRONT/src
flutter pub get
```

## ⚙️ Configuração
Antes de rodar o projeto, é necessário configurar alguns arquivos **não incluídos no repositório** por conterem informações sensíveis:  

- Coloque o arquivo `firebase.json` dentro da pasta:  
  ```
  src/lib/core/client/
  ```

- Crie ou adicione o arquivo `.env` na **raiz do projeto**:  
  ```
  API-5-FRONT/.env
  ```

> ⚠️ Esses arquivos não estão disponíveis neste repositório. Solicite ao responsável pelo projeto ou configure-os conforme a documentação oficial (Firebase e variáveis de ambiente necessárias).  

## ▶️ Execução
Rodar aplicação em dispositivo ou emulador:  
```bash
flutter run
```

## 🌐 Build para Web
Gerar build para versão web:  
```bash
flutter build web
```

## 📁 Estrutura de Diretórios
```
lib/
├── core/                          # Camada de núcleo da aplicação
│   ├── client/                    # Cliente HTTP e configurações de rede
│   │   └── http_client.dart       # Configuração do Dio/HTTP client
│   ├── constants/                 # Constantes globais da aplicação
│   ├── providers/                 # Providers do Riverpod/GetIt para injeção de dependência
│   ├── routing/                   # Configuração de rotas e navegação
│   ├── services/                  # Serviços de negócio
│   │   ├── alert_service.dart     # Gerenciamento de alertas
│   │   ├── api_service.dart       # Serviço genérico de API
│   │   ├── appointment_service.dart
│   │   ├── auth_service.dart      # Autenticação e login
│   │   ├── exam_service.dart
│   │   ├── file_service.dart      # Upload/download de arquivos
│   │   ├── merchandise_service.dart
│   │   ├── merchandise_log_service.dart
│   │   ├── order_service.dart
│   │   ├── patient_service.dart
│   │   ├── report_service.dart
│   │   ├── section_service.dart
│   │   ├── stock_service.dart
│   │   └── user_service.dart
│   └── utils/                     # Funções utilitárias
│
├── data/                          # Camada de dados (modelos e respostas)
│   ├── enums/                     # Enumerações (roles, status, etc)
│   ├── models/                    # Modelos de dados da aplicação
│   └── responses/                 # Modelos de resposta da API
│
├── ui/                            # Camada de apresentação
│   ├── viewmodels/                # ViewModels/Controllers de lógica de tela
│   ├── views/                     # Telas/páginas da aplicação
│   │   ├── alerts/                # Tela de alertas de estoque
│   │   ├── appointments/          # Tela de agendamentos
│   │   ├── exam_types/            # Tela de tipos de exame
│   │   ├── forgot_password/       # Tela de recuperação de senha
│   │   ├── home/                  # Tela inicial/dashboard
│   │   ├── inventory/             # Tela de inventário
│   │   ├── login/                 # Tela de login
│   │   ├── merchandise/           # Tela de mercadorias
│   │   ├── orders/                # Tela de pedidos
│   │   ├── patients/              # Tela de pacientes
│   │   ├── profile/               # Tela de perfil do usuário
│   │   ├── reports/               # Tela de relatórios
│   │   ├── section/               # Tela de seções
│   │   ├── stock/                 # Tela de estoque
│   │   └── users/                 # Tela de gerenciamento de usuários
│   └── widgets/                   # Componentes reutilizáveis
│       ├── add_floating_button.dart
│       ├── alert_card.dart
│       ├── background_header.dart
│       ├── bottom_nav_bar_widget.dart
│       ├── change_password_modal.dart
│       ├── custom_card.dart
│       ├── custom_modal.dart
│       ├── header_icon.dart
│       ├── merchandise_card.dart
│       ├── order_card.dart
│       ├── role_gate.dart
│       └── scan_or_manual_dialog.dart
│
├── examples/                      # Exemplos de uso
│   └── api_usage_example.dart
│
├── firebase_options.dart          # Configurações do Firebase
└── main.dart                      # Ponto de entrada da aplicação   
```

## 👥 Time
| Nome | Função |
|------|--------|
| José Eduardo Fernandes| Scrum Master |
| Ana Laura Moratelli | Product Owner |
| Arthur Karnas | Desenvolvedora |
| Erik Yokota | Desenvolvedor |
| Filipe Colla | Desenvolvedor |
| João Gabriel Solis  | Desenvolvedor |
| Kauê Francisco | Desenvolvedor |
