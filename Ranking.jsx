import { useState, useEffect } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, BarChart, Bar } from 'recharts'
import { Trophy, TrendingUp, Award, Target, Calendar } from 'lucide-react'

const Ranking = () => {
  const [competitions, setCompetitions] = useState([])
  const [ranking, setRanking] = useState({})
  const [stats, setStats] = useState({})
  const [selectedCompetition, setSelectedCompetition] = useState(null)
  const [evolutionData, setEvolutionData] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchData()
  }, [])

  const fetchData = async () => {
    try {
      // Buscar competições
      const competitionsRes = await fetch('/api/competitions')
      const competitionsData = await competitionsRes.json()
      if (competitionsData.success) {
        setCompetitions(competitionsData.data)
      }

      // Buscar ranking geral
      const rankingRes = await fetch('/api/competitions/ranking')
      const rankingData = await rankingRes.json()
      if (rankingData.success) {
        setRanking(rankingData.data)
      }

      // Buscar estatísticas
      const statsRes = await fetch('/api/competitions/stats')
      const statsData = await statsRes.json()
      if (statsData.success) {
        setStats(statsData.data)
      }
    } catch (error) {
      console.error('Erro ao carregar dados de ranking:', error)
    } finally {
      setLoading(false)
    }
  }

  const fetchEvolution = async (competitionId) => {
    try {
      const response = await fetch(`/api/competitions/${competitionId}/evolution`)
      const data = await response.json()
      if (data.success) {
        setEvolutionData(data.data.evolution)
        setSelectedCompetition(data.data.competition)
      }
    } catch (error) {
      console.error('Erro ao carregar evolução:', error)
    }
  }

  const formatRankingData = () => {
    return Object.entries(ranking).map(([competition, scores]) => ({
      competition: competition.length > 20 ? competition.substring(0, 20) + '...' : competition,
      fullName: competition,
      latestScore: scores.length > 0 ? scores[scores.length - 1].score : 0,
      totalParticipations: scores.length,
      bestScore: Math.max(...scores.map(s => s.score)),
      avgScore: scores.reduce((acc, s) => acc + s.score, 0) / scores.length
    }))
  }

  if (loading) {
    return (
      <div className="space-y-6">
        <div className="animate-pulse">
          <div className="h-8 bg-gray-200 rounded w-1/4 mb-6"></div>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            {[...Array(3)].map((_, i) => (
              <div key={i} className="h-32 bg-gray-200 rounded-lg"></div>
            ))}
          </div>
        </div>
      </div>
    )
  }

  const rankingData = formatRankingData()

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Ranking</h1>
          <p className="text-gray-600 mt-1">Acompanhe seu desempenho nas competições</p>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Total de Competições</CardTitle>
            <Trophy className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.total_competitions || 0}</div>
            <p className="text-xs text-muted-foreground">
              Modalidades participadas
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Pontuação Média</CardTitle>
            <TrendingUp className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.average_score || 0}</div>
            <p className="text-xs text-muted-foreground">
              Média geral das competições
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
            <CardTitle className="text-sm font-medium">Melhor Pontuação</CardTitle>
            <Award className="h-4 w-4 text-muted-foreground" />
          </CardHeader>
          <CardContent>
            <div className="text-2xl font-bold">{stats.best_score?.score || 0}</div>
            <p className="text-xs text-muted-foreground">
              {stats.best_score?.competition || 'Nenhuma competição'}
            </p>
          </CardContent>
        </Card>
      </div>

      <Tabs defaultValue="overview" className="space-y-4">
        <TabsList>
          <TabsTrigger value="overview">Visão Geral</TabsTrigger>
          <TabsTrigger value="evolution">Evolução</TabsTrigger>
          <TabsTrigger value="competitions">Competições</TabsTrigger>
        </TabsList>

        <TabsContent value="overview" className="space-y-4">
          {/* Ranking Chart */}
          <Card>
            <CardHeader>
              <CardTitle>Ranking por Modalidade</CardTitle>
              <CardDescription>Comparação de desempenho entre diferentes competições</CardDescription>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={400}>
                <BarChart data={rankingData}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="competition" />
                  <YAxis />
                  <Tooltip 
                    formatter={(value, name) => [value, name === 'latestScore' ? 'Última Pontuação' : 'Melhor Pontuação']}
                    labelFormatter={(label) => {
                      const item = rankingData.find(d => d.competition === label)
                      return item ? item.fullName : label
                    }}
                  />
                  <Legend />
                  <Bar dataKey="latestScore" fill="#3b82f6" name="Última Pontuação" />
                  <Bar dataKey="bestScore" fill="#f59e0b" name="Melhor Pontuação" />
                </BarChart>
              </ResponsiveContainer>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="evolution" className="space-y-4">
          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            {/* Competition Selection */}
            <Card>
              <CardHeader>
                <CardTitle>Selecionar Competição</CardTitle>
                <CardDescription>Escolha uma competição para ver a evolução</CardDescription>
              </CardHeader>
              <CardContent>
                <div className="space-y-2">
                  {competitions.map((competition) => (
                    <Button
                      key={competition.id}
                      variant={selectedCompetition?.id === competition.id ? "default" : "outline"}
                      className="w-full justify-start"
                      onClick={() => fetchEvolution(competition.id)}
                    >
                      <Trophy className="h-4 w-4 mr-2" />
                      {competition.name}
                    </Button>
                  ))}
                </div>
              </CardContent>
            </Card>

            {/* Evolution Chart */}
            <Card className="lg:col-span-2">
              <CardHeader>
                <CardTitle>
                  {selectedCompetition ? `Evolução - ${selectedCompetition.name}` : 'Selecione uma Competição'}
                </CardTitle>
                <CardDescription>
                  {selectedCompetition ? 'Histórico de pontuações ao longo do tempo' : 'Escolha uma competição para visualizar a evolução'}
                </CardDescription>
              </CardHeader>
              <CardContent>
                {evolutionData.length > 0 ? (
                  <ResponsiveContainer width="100%" height={300}>
                    <LineChart data={evolutionData}>
                      <CartesianGrid strokeDasharray="3 3" />
                      <XAxis dataKey="date" />
                      <YAxis />
                      <Tooltip />
                      <Legend />
                      <Line 
                        type="monotone" 
                        dataKey="score" 
                        stroke="#3b82f6" 
                        strokeWidth={2}
                        dot={{ fill: '#3b82f6' }}
                        name="Pontuação"
                      />
                    </LineChart>
                  </ResponsiveContainer>
                ) : (
                  <div className="flex items-center justify-center h-64 text-gray-500">
                    <div className="text-center">
                      <Target className="h-12 w-12 mx-auto mb-4 opacity-50" />
                      <p>Selecione uma competição para ver a evolução</p>
                    </div>
                  </div>
                )}
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        <TabsContent value="competitions" className="space-y-4">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {competitions.map((competition) => {
              const competitionScores = ranking[competition.name] || []
              const latestScore = competitionScores.length > 0 ? competitionScores[competitionScores.length - 1] : null
              const bestScore = competitionScores.length > 0 ? Math.max(...competitionScores.map(s => s.score)) : 0
              
              return (
                <Card key={competition.id} className="hover:shadow-lg transition-shadow">
                  <CardHeader>
                    <div className="flex items-center justify-between">
                      <div className="w-12 h-12 bg-yellow-100 rounded-lg flex items-center justify-center">
                        <Trophy className="h-6 w-6 text-yellow-600" />
                      </div>
                      <Badge variant="secondary">
                        {competitionScores.length} etapas
                      </Badge>
                    </div>
                    <CardTitle className="text-lg">{competition.name}</CardTitle>
                    <CardDescription>{competition.description}</CardDescription>
                  </CardHeader>
                  <CardContent>
                    <div className="space-y-3">
                      <div className="flex justify-between">
                        <span className="text-sm text-gray-600">Última Pontuação:</span>
                        <span className="font-semibold">{latestScore?.score || 'N/A'}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-sm text-gray-600">Melhor Pontuação:</span>
                        <span className="font-semibold text-green-600">{bestScore || 'N/A'}</span>
                      </div>
                      <div className="flex justify-between">
                        <span className="text-sm text-gray-600">Última Participação:</span>
                        <span className="text-sm">
                          {latestScore?.date 
                            ? new Date(latestScore.date).toLocaleDateString('pt-BR')
                            : 'Nunca'
                          }
                        </span>
                      </div>
                      <Button 
                        variant="outline" 
                        size="sm" 
                        className="w-full"
                        onClick={() => fetchEvolution(competition.id)}
                      >
                        <Calendar className="h-4 w-4 mr-2" />
                        Ver Evolução
                      </Button>
                    </div>
                  </CardContent>
                </Card>
              )
            })}
          </div>

          {competitions.length === 0 && (
            <div className="text-center py-12">
              <Trophy className="h-16 w-16 mx-auto mb-4 text-gray-400" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">Nenhuma competição encontrada</h3>
              <p className="text-gray-600">
                As competições serão exibidas aqui conforme você participar delas.
              </p>
            </div>
          )}
        </TabsContent>
      </Tabs>
    </div>
  )
}

export default Ranking

