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

## 📋 Sobre
O frontend é responsável por:
- Interface simples e responsiva
- Autenticação via login
- Leitura de QR Codes para identificação rápida
- Alertas visuais
- Integração com o backend

## 🚀 Tecnologias
- **React**
- **TypeScript**
- **Flutter**
- **HTML5**
- **CSS3**

## ⚙️ Funcionalidades
- Login e autenticação
- Dashboard com visão de estoque
- Busca por QR Code
- Alertas de estoque
- Relatórios visuais

## 📚 Rotas
```typescript
/              # Landing Page
/login         # Página de login
/estoque       # Gerenciamento de estoque
/itens         # Cadastro de itens
/alertas       # Alertas de estoque
/usuarios      # Gestão de usuários
# a completar
```

## 🚦 Como Executar

### Pré-requisitos
- Flutter SDK (3.x)
- Node.js (se for usar versão web)
- Android Studio ou VSCode configurado

### Instalação
```bash
git clone https://github.com/seu-usuario/projeto-frontend.git
cd projeto-frontend
flutter pub get
```

Rodar aplicação em dispositivo ou emulador:
```bash
flutter run
```

Build web:
```bash
flutter build web
```

## 📁 Estrutura de Diretórios
```
lib/
├── api/          
├── components/    
├── pages/         
├── hooks/         
├── contexts/      
└── utils/         
```

## 👥 Time
| Nome | Função |
|------|--------|
| João Gabriel Solis | Scrum Master |
| Ana Laura Moratelli | Product Owner |
| Arthur Karnas | Desenvolvedora |
| Erik Yokota | Desenvolvedor |
| Filipe Colla | Desenvolvedor |
| José Eduardo Fernandes | Desenvolvedor |
| Kauê Francisco | Desenvolvedor |

## 📄 Licença
MIT
