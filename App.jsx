import { useState, useEffect } from 'react'
import { Target, Trophy, Zap, BarChart3, Settings, Menu, X, LogOut, User } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { AuthProvider, useAuth } from './contexts/AuthContext'
import AuthPage from './components/AuthPage'
import Dashboard from './components/Dashboard'
import Arsenal from './components/Arsenal'
import Ranking from './components/Ranking'
import Training from './components/Training'
import Levels from './components/Levels'
import './App.css'

const navigation = [
  { name: 'Dashboard', icon: BarChart3, id: 'dashboard' },
  { name: 'Arsenal', icon: Target, id: 'arsenal' },
  { name: 'Ranking', icon: Trophy, id: 'ranking' },
  { name: 'Treinamento', icon: Zap, id: 'training' },
  { name: 'Níveis', icon: Settings, id: 'levels' },
]

function AppContent() {
  const [activeTab, setActiveTab] = useState('dashboard')
  const [sidebarOpen, setSidebarOpen] = useState(false)
  const [userLevel, setUserLevel] = useState(null)
  
  const { user, loading, logout, isAuthenticated, token } = useAuth()

  useEffect(() => {
    if (isAuthenticated && token) {
      // Buscar nível atual do usuário
      fetch('/api/progress', {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      })
        .then(res => res.json())
        .then(data => {
          if (data.success && data.data) {
            setUserLevel(data.data.current_level)
          }
        })
        .catch(err => console.error('Erro ao buscar progresso:', err))
    }
  }, [isAuthenticated, token])

  const renderContent = () => {
    switch (activeTab) {
      case 'dashboard':
        return <Dashboard />
      case 'arsenal':
        return <Arsenal />
      case 'ranking':
        return <Ranking />
      case 'training':
        return <Training />
      case 'levels':
        return <Levels />
      default:
        return <Dashboard />
    }
  }

  const handleLogout = () => {
    logout()
    setActiveTab('dashboard')
    setSidebarOpen(false)
  }

  // Mostrar loading enquanto verifica autenticação
  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-blue-50 to-orange-50">
        <div className="text-center">
          <div className="bg-blue-600 p-4 rounded-full mb-4 inline-block">
            <Target className="h-8 w-8 text-white animate-spin" />
          </div>
          <p className="text-gray-600">Carregando...</p>
        </div>
      </div>
    )
  }

  // Mostrar página de autenticação se não estiver logado
  if (!isAuthenticated) {
    return <AuthPage />
  }

  // Aplicação principal para usuários autenticados
  return (
    <div className="min-h-screen bg-gray-50">
      {/* Sidebar */}
      <div className={`fixed inset-y-0 left-0 z-50 w-64 bg-white shadow-lg transform ${
        sidebarOpen ? 'translate-x-0' : '-translate-x-full'
      } transition-transform duration-300 ease-in-out lg:translate-x-0 lg:static lg:inset-0`}>
        
        {/* Header da Sidebar */}
        <div className="flex items-center justify-between h-16 px-6 border-b border-gray-200">
          <div className="flex items-center space-x-3">
            <div className="bg-blue-600 p-2 rounded-lg">
              <Target className="h-6 w-6 text-white" />
            </div>
            <div>
              <h1 className="text-lg font-bold text-gray-900">Shooting Sports</h1>
              <p className="text-xs text-gray-500">Controle de Tiro</p>
            </div>
          </div>
          <Button
            variant="ghost"
            size="sm"
            onClick={() => setSidebarOpen(false)}
            className="lg:hidden"
          >
            <X className="h-4 w-4" />
          </Button>
        </div>

        {/* Informações do Usuário */}
        <div className="p-4 border-b border-gray-200">
          <Card className="bg-blue-50 border-blue-200">
            <CardContent className="p-4">
              <div className="flex items-center space-x-3 mb-2">
                <div className="bg-blue-600 p-2 rounded-full">
                  <User className="h-4 w-4 text-white" />
                </div>
                <div className="flex-1 min-w-0">
                  <p className="text-sm font-medium text-gray-900 truncate">
                    {user?.full_name || user?.username}
                  </p>
                  <p className="text-xs text-gray-500 truncate">
                    {user?.email}
                  </p>
                </div>
              </div>
              
              {userLevel && (
                <div>
                  <div className="flex items-center justify-between mb-1">
                    <span className="text-xs font-medium text-gray-700">
                      {userLevel.name}
                    </span>
                    <Badge variant="outline" className="text-xs">
                      Nível {userLevel.order}
                    </Badge>
                  </div>
                  <p className="text-xs text-gray-600 mb-2">
                    {userLevel.message}
                  </p>
                </div>
              )}
            </CardContent>
          </Card>
        </div>

        {/* Navegação */}
        <nav className="flex-1 px-4 py-4 space-y-2">
          {navigation.map((item) => {
            const Icon = item.icon
            const isActive = activeTab === item.id
            
            return (
              <button
                key={item.id}
                onClick={() => {
                  setActiveTab(item.id)
                  setSidebarOpen(false)
                }}
                className={`w-full flex items-center px-3 py-2 text-sm font-medium rounded-lg transition-colors ${
                  isActive
                    ? 'bg-blue-100 text-blue-700 border-2 border-blue-200'
                    : 'text-gray-600 hover:bg-gray-100 hover:text-gray-900'
                }`}
              >
                <Icon className="mr-3 h-5 w-5" />
                {item.name}
              </button>
            )
          })}
        </nav>

        {/* Logout */}
        <div className="p-4 border-t border-gray-200">
          <Button
            variant="ghost"
            onClick={handleLogout}
            className="w-full justify-start text-red-600 hover:text-red-700 hover:bg-red-50"
          >
            <LogOut className="mr-3 h-4 w-4" />
            Sair
          </Button>
        </div>

        {/* Versão */}
        <div className="p-4 text-center">
          <p className="text-xs text-gray-400">Shooting Sports v1.0</p>
        </div>
      </div>

      {/* Overlay para mobile */}
      {sidebarOpen && (
        <div
          className="fixed inset-0 bg-black bg-opacity-50 z-40 lg:hidden"
          onClick={() => setSidebarOpen(false)}
        />
      )}

      {/* Conteúdo Principal */}
      <div className="lg:pl-64">
        {/* Header Mobile */}
        <div className="lg:hidden flex items-center justify-between h-16 px-4 bg-white border-b border-gray-200">
          <Button
            variant="ghost"
            size="sm"
            onClick={() => setSidebarOpen(true)}
          >
            <Menu className="h-5 w-5" />
          </Button>
          <h1 className="text-lg font-semibold text-gray-900">
            {navigation.find(item => item.id === activeTab)?.name || 'Dashboard'}
          </h1>
          <div className="w-10" /> {/* Spacer */}
        </div>

        {/* Conteúdo */}
        <main className="p-4 lg:p-6">
          {renderContent()}
        </main>
      </div>
    </div>
  )
}

function App() {
  return (
    <AuthProvider>
      <AppContent />
    </AuthProvider>
  )
}

export default App

