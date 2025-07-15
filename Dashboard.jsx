import { useState, useEffect } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Target, Trophy, Zap, TrendingUp, Calendar, Award } from 'lucide-react'

const Dashboard = () => {
  const [stats, setStats] = useState({
    general: {
      total_sessions: 0,
      total_shots: 0,
      total_hits: 0,
      avg_accuracy: 0,
      avg_score: 0
    },
    evolution: []
  })
  const [progress, setProgress] = useState(null)
  const [recentSessions, setRecentSessions] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const fetchData = async () => {
      try {
        // Buscar estatísticas de treinamento
        const statsRes = await fetch('/api/training-sessions/stats')
        const statsData = await statsRes.json()
        if (statsData.success) {
          setStats(statsData.data)
        }

        // Buscar progresso do usuário
        const progressRes = await fetch('/api/progress')
        const progressData = await progressRes.json()
        if (progressData.success) {
          setProgress(progressData.data)
        }

        // Buscar sessões recentes
        const sessionsRes = await fetch('/api/training-sessions/recent?limit=5')
        const sessionsData = await sessionsRes.json()
        if (sessionsData.success) {
          setRecentSessions(sessionsData.data)
        }
      } catch (error) {
        console.error('Erro ao carregar dados do dashboard:', error)
      } finally {
        setLoading(false)
      }
    }

    fetchData()
  }, [])

  if (loading) {
    return (
      <div className="space-y-6">
        <div className="animate-pulse">
          <div className="h-8 bg-gray-200 rounded w-1/4 mb-6"></div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            {[...Array(4)].map((_, i) => (
              <div key={i} className="h-32 bg-gray-200 rounded-lg"></div>
            ))}
          </div>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
          <p className="text-gray-600 mt-1">Visão geral das suas atividades de tiro esportivo</p>
        </div>
        <Button className="bg-blue-600 hover:bg-blue-700">
          <Calendar className="h-4 w-4 mr-2" />
          Nova Sessão
        </Button>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total de Sessões</CardTitle>
            <Zap className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.general.total_sessions}</div>
            <p className="text-xs text-muted-foreground">
              Sessões de treinamento realizadas
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Disparos Totais</CardTitle>
            <Target className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.general.total_shots}</div>
            <p className="text-xs text-muted-foreground">
              {stats.general.total_hits} acertos
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Precisão Média</CardTitle>
            <TrendingUp className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.general.avg_accuracy.toFixed(1)}%</div>
            <p className="text-xs text-muted-foreground">
              Taxa de acerto geral
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Pontuação Média</CardTitle>
            <Trophy className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.general.avg_score.toFixed(1)}</div>
            <p className="text-xs text-muted-foreground">
              Pontos por sessão
            </p>
          </CardContent>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Nível Atual */}
        {progress && (
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center">
                <Award className="h-5 w-5 mr-2" />
                Nível Atual
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <div>
                    <h3 className="text-lg font-semibold">{progress.current_level?.name}</h3>
                    <p className="text-sm text-gray-600">{progress.current_level?.message}</p>
                  </div>
                  <Badge variant="secondary" className="bg-blue-100 text-blue-800">
                    Nível {progress.current_level?.order}
                  </Badge>
                </div>
                
                <div className="space-y-2">
                  <div className="flex justify-between text-sm">
                    <span>Progresso</span>
                    <span>{progress.average_score.toFixed(1)} pts</span>
                  </div>
                  <div className="w-full bg-gray-200 rounded-full h-2">
                    <div 
                      className="bg-blue-600 h-2 rounded-full transition-all duration-300"
                      style={{ width: `${Math.min(100, (progress.average_score / 200) * 100)}%` }}
                    ></div>
                  </div>
                </div>

                <div className="grid grid-cols-2 gap-4 text-sm">
                  <div>
                    <p className="text-gray-600">Precisão Geral</p>
                    <p className="font-semibold">{progress.overall_accuracy.toFixed(1)}%</p>
                  </div>
                  <div>
                    <p className="text-gray-600">Última Sessão</p>
                    <p className="font-semibold">
                      {progress.last_session_date 
                        ? new Date(progress.last_session_date).toLocaleDateString('pt-BR')
                        : 'Nunca'
                      }
                    </p>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        )}

        {/* Sessões Recentes */}
        <Card>
          <CardHeader>
            <CardTitle>Sessões Recentes</CardTitle>
            <CardDescription>Suas últimas atividades de treinamento</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-4">
              {recentSessions.length > 0 ? (
                recentSessions.map((session, index) => (
                  <div key={session.id || index} className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                    <div className="flex items-center space-x-3">
                      <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
                        <Target className="h-5 w-5 text-blue-600" />
                      </div>
                      <div>
                        <p className="font-medium">{session.weapon_name}</p>
                        <p className="text-sm text-gray-600">
                          {session.date 
                            ? new Date(session.date).toLocaleDateString('pt-BR')
                            : 'Data não informada'
                          }
                        </p>
                      </div>
                    </div>
                    <div className="text-right">
                      <p className="font-semibold">{session.accuracy?.toFixed(1)}%</p>
                      <p className="text-sm text-gray-600">
                        {session.hits}/{session.shots_fired} acertos
                      </p>
                    </div>
                  </div>
                ))
              ) : (
                <div className="text-center py-8 text-gray-500">
                  <Target className="h-12 w-12 mx-auto mb-4 opacity-50" />
                  <p>Nenhuma sessão encontrada</p>
                  <p className="text-sm">Comece seu primeiro treinamento!</p>
                </div>
              )}
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}

export default Dashboard

