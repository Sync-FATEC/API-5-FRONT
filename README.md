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
| José Eduardo Fernandes| Scrum Master |
| Ana Laura Moratelli | Product Owner |
| Arthur Karnas | Desenvolvedora |
| Erik Yokota | Desenvolvedor |
| Filipe Colla | Desenvolvedor |
| João Gabriel Solis  | Desenvolvedor |
| Kauê Francisco | Desenvolvedor |
