// Configuração do Frontend para TIROESPORTIVOBRASILEIRO.COM.BR
// Este arquivo contém as configurações específicas para o domínio personalizado

const config = {
  // URLs da API
  API_BASE_URL: process.env.NODE_ENV === 'production' 
    ? 'https://tiroesportivobrasileiro.com.br/api'
    : 'http://localhost:5000/api',
  
  // Configurações do domínio
  DOMAIN: 'tiroesportivobrasileiro.com.br',
  SITE_NAME: 'Tiro Esportivo Brasileiro',
  SITE_DESCRIPTION: 'Sistema de Controle de Tiro Esportivo',
  
  // URLs completas
  SITE_URL: 'https://tiroesportivobrasileiro.com.br',
  
  // Configurações de autenticação
  AUTH: {
    TOKEN_KEY: 'tiroesportivo_token',
    USER_KEY: 'tiroesportivo_user',
    COOKIE_DOMAIN: '.tiroesportivobrasileiro.com.br',
    SECURE_COOKIES: true
  },
  
  // Configurações de SEO
  SEO: {
    TITLE: 'Tiro Esportivo Brasileiro - Sistema de Controle',
    KEYWORDS: 'tiro esportivo, controle, ranking, competições, armas, treinamento',
    AUTHOR: 'Tiro Esportivo Brasileiro',
    ROBOTS: 'index, follow',
    CANONICAL_URL: 'https://tiroesportivobrasileiro.com.br'
  },
  
  // Configurações de segurança
  SECURITY: {
    HTTPS_ONLY: true,
    SECURE_HEADERS: true,
    CSP_ENABLED: true
  },
  
  // Configurações de analytics (opcional)
  ANALYTICS: {
    GOOGLE_ANALYTICS_ID: process.env.GOOGLE_ANALYTICS_ID || '',
    MICROSOFT_CLARITY_ID: process.env.MICROSOFT_CLARITY_ID || ''
  },
  
  // Configurações de contato
  CONTACT: {
    EMAIL: 'contato@tiroesportivobrasileiro.com.br',
    PHONE: '+55 (11) 99999-9999',
    ADDRESS: 'Brasil'
  },
  
  // Configurações de redes sociais
  SOCIAL: {
    FACEBOOK: 'https://facebook.com/tiroesportivobrasileiro',
    INSTAGRAM: 'https://instagram.com/tiroesportivobrasileiro',
    TWITTER: 'https://twitter.com/tiroesportivobr',
    YOUTUBE: 'https://youtube.com/tiroesportivobrasileiro'
  }
};

// Exportar configuração
if (typeof module !== 'undefined' && module.exports) {
  module.exports = config;
} else if (typeof window !== 'undefined') {
  window.APP_CONFIG = config;
}

export default config;

