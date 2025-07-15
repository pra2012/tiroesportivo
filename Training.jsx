import { useState, useEffect } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import { Zap, Plus, Target, Clock, Calendar, TrendingUp, Edit, Trash2 } from 'lucide-react'

const Training = () => {
  const [sessions, setSessions] = useState([])
  const [weapons, setWeapons] = useState([])
  const [stats, setStats] = useState({})
  const [loading, setLoading] = useState(true)
  const [isAddDialogOpen, setIsAddDialogOpen] = useState(false)
  const [editingSession, setEditingSession] = useState(null)
  const [newSession, setNewSession] = useState({
    weapon_id: '',
    shots_fired: '',
    hits: '',
    score: '',
    notes: '',
    duration_minutes: '',
    date: new Date().toISOString().split('T')[0]
  })

  useEffect(() => {
    fetchData()
  }, [])

  const fetchData = async () => {
    try {
      // Buscar sessões de treinamento
      const sessionsRes = await fetch('/api/training-sessions?per_page=20')
      const sessionsData = await sessionsRes.json()
      if (sessionsData.success) {
        setSessions(sessionsData.data.sessions)
      }

      // Buscar armas
      const weaponsRes = await fetch('/api/weapons')
      const weaponsData = await weaponsRes.json()
      if (weaponsData.success) {
        setWeapons(weaponsData.data)
      }

      // Buscar estatísticas
      const statsRes = await fetch('/api/training-sessions/stats')
      const statsData = await statsRes.json()
      if (statsData.success) {
        setStats(statsData.data)
      }
    } catch (error) {
      console.error('Erro ao carregar dados de treinamento:', error)
    } finally {
      setLoading(false)
    }
  }

  const handleAddSession = async () => {
    try {
      const sessionData = {
        ...newSession,
        weapon_id: parseInt(newSession.weapon_id),
        shots_fired: parseInt(newSession.shots_fired),
        hits: parseInt(newSession.hits),
        score: parseFloat(newSession.score),
        duration_minutes: parseInt(newSession.duration_minutes)
      }

      const response = await fetch('/api/training-sessions', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(sessionData),
      })
      const data = await response.json()
      if (data.success) {
        setSessions([data.data, ...sessions])
        setNewSession({
          weapon_id: '',
          shots_fired: '',
          hits: '',
          score: '',
          notes: '',
          duration_minutes: '',
          date: new Date().toISOString().split('T')[0]
        })
        setIsAddDialogOpen(false)
        // Atualizar estatísticas
        fetchData()
      }
    } catch (error) {
      console.error('Erro ao adicionar sessão:', error)
    }
  }

  const handleEditSession = async (session) => {
    try {
      const response = await fetch(`/api/training-sessions/${session.id}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(session),
      })
      const data = await response.json()
      if (data.success) {
        setSessions(sessions.map(s => s.id === session.id ? data.data : s))
        setEditingSession(null)
        fetchData()
      }
    } catch (error) {
      console.error('Erro ao editar sessão:', error)
    }
  }

  const handleDeleteSession = async (sessionId) => {
    if (confirm('Tem certeza que deseja excluir esta sessão?')) {
      try {
        const response = await fetch(`/api/training-sessions/${sessionId}`, {
          method: 'DELETE',
        })
        const data = await response.json()
        if (data.success) {
          setSessions(sessions.filter(s => s.id !== sessionId))
          fetchData()
        }
      } catch (error) {
        console.error('Erro ao excluir sessão:', error)
      }
    }
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

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Treinamento</h1>
          <p className="text-gray-600 mt-1">Gerencie suas sessões de treinamento</p>
        </div>
        <Dialog open={isAddDialogOpen} onOpenChange={setIsAddDialogOpen}>
          <DialogTrigger asChild>
            <Button className="bg-blue-600 hover:bg-blue-700">
              <Plus className="h-4 w-4 mr-2" />
              Nova Sessão
            </Button>
          </DialogTrigger>
          <DialogContent className="max-w-2xl">
            <DialogHeader>
              <DialogTitle>Nova Sessão de Treinamento</DialogTitle>
              <DialogDescription>
                Registre os dados da sua sessão de treinamento.
              </DialogDescription>
            </DialogHeader>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <Label htmlFor="weapon">Arma</Label>
                <Select value={newSession.weapon_id} onValueChange={(value) => setNewSession({ ...newSession, weapon_id: value })}>
                  <SelectTrigger>
                    <SelectValue placeholder="Selecione a arma" />
                  </SelectTrigger>
                  <SelectContent>
                    {weapons.map(weapon => (
                      <SelectItem key={weapon.id} value={weapon.id.toString()}>
                        {weapon.name} ({weapon.caliber})
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div>
                <Label htmlFor="date">Data</Label>
                <Input
                  id="date"
                  type="date"
                  value={newSession.date}
                  onChange={(e) => setNewSession({ ...newSession, date: e.target.value })}
                />
              </div>
              <div>
                <Label htmlFor="shots">Disparos</Label>
                <Input
                  id="shots"
                  type="number"
                  value={newSession.shots_fired}
                  onChange={(e) => setNewSession({ ...newSession, shots_fired: e.target.value })}
                  placeholder="Número de disparos"
                />
              </div>
              <div>
                <Label htmlFor="hits">Acertos</Label>
                <Input
                  id="hits"
                  type="number"
                  value={newSession.hits}
                  onChange={(e) => setNewSession({ ...newSession, hits: e.target.value })}
                  placeholder="Número de acertos"
                />
              </div>
              <div>
                <Label htmlFor="score">Pontuação</Label>
                <Input
                  id="score"
                  type="number"
                  step="0.1"
                  value={newSession.score}
                  onChange={(e) => setNewSession({ ...newSession, score: e.target.value })}
                  placeholder="Pontuação obtida"
                />
              </div>
              <div>
                <Label htmlFor="duration">Duração (min)</Label>
                <Input
                  id="duration"
                  type="number"
                  value={newSession.duration_minutes}
                  onChange={(e) => setNewSession({ ...newSession, duration_minutes: e.target.value })}
                  placeholder="Duração em minutos"
                />
              </div>
              <div className="col-span-2">
                <Label htmlFor="notes">Observações</Label>
                <Textarea
                  id="notes"
                  value={newSession.notes}
                  onChange={(e) => setNewSession({ ...newSession, notes: e.target.value })}
                  placeholder="Observações sobre a sessão..."
                  rows={3}
                />
              </div>
            </div>
            <div className="flex justify-end space-x-2">
              <Button variant="outline" onClick={() => setIsAddDialogOpen(false)}>
                Cancelar
              </Button>
              <Button 
                onClick={handleAddSession} 
                disabled={!newSession.weapon_id || !newSession.shots_fired || !newSession.hits}
              >
                Adicionar
              </Button>
            </div>
          </DialogContent>
        </Dialog>
      </div>

      <Tabs defaultValue="overview" className="space-y-4">
        <TabsList>
          <TabsTrigger value="overview">Visão Geral</TabsTrigger>
          <TabsTrigger value="sessions">Sessões</TabsTrigger>
          <TabsTrigger value="statistics">Estatísticas</TabsTrigger>
        </TabsList>

        <TabsContent value="overview" className="space-y-4">
          {/* Stats Cards */}
          <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Total de Sessões</CardTitle>
                <Zap className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{stats.general?.total_sessions || 0}</div>
                <p className="text-xs text-muted-foreground">
                  Sessões realizadas
                </p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Disparos Totais</CardTitle>
                <Target className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{stats.general?.total_shots || 0}</div>
                <p className="text-xs text-muted-foreground">
                  {stats.general?.total_hits || 0} acertos
                </p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Precisão Média</CardTitle>
                <TrendingUp className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{stats.general?.avg_accuracy?.toFixed(1) || 0}%</div>
                <p className="text-xs text-muted-foreground">
                  Taxa de acerto
                </p>
              </CardContent>
            </Card>

            <Card>
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-sm font-medium">Pontuação Média</CardTitle>
                <TrendingUp className="h-4 w-4 text-muted-foreground" />
              </CardHeader>
              <CardContent>
                <div className="text-2xl font-bold">{stats.general?.avg_score?.toFixed(1) || 0}</div>
                <p className="text-xs text-muted-foreground">
                  Pontos por sessão
                </p>
              </CardContent>
            </Card>
          </div>

          {/* Recent Sessions */}
          <Card>
            <CardHeader>
              <CardTitle>Sessões Recentes</CardTitle>
              <CardDescription>Suas últimas 5 sessões de treinamento</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {sessions.slice(0, 5).map((session) => (
                  <div key={session.id} className="flex items-center justify-between p-4 bg-gray-50 rounded-lg">
                    <div className="flex items-center space-x-4">
                      <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                        <Target className="h-6 w-6 text-blue-600" />
                      </div>
                      <div>
                        <p className="font-medium">{session.weapon_name}</p>
                        <p className="text-sm text-gray-600">
                          {new Date(session.date).toLocaleDateString('pt-BR')}
                        </p>
                      </div>
                    </div>
                    <div className="text-right">
                      <div className="flex items-center space-x-4">
                        <div>
                          <p className="font-semibold">{session.accuracy?.toFixed(1)}%</p>
                          <p className="text-sm text-gray-600">
                            {session.hits}/{session.shots_fired}
                          </p>
                        </div>
                        <Badge variant="secondary">
                          {session.score} pts
                        </Badge>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="sessions" className="space-y-4">
          <div className="grid grid-cols-1 gap-4">
            {sessions.map((session) => (
              <Card key={session.id} className="hover:shadow-md transition-shadow">
                <CardContent className="p-6">
                  <div className="flex items-center justify-between">
                    <div className="flex items-center space-x-4">
                      <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                        <Target className="h-6 w-6 text-blue-600" />
                      </div>
                      <div>
                        <h3 className="font-semibold text-lg">{session.weapon_name}</h3>
                        <div className="flex items-center space-x-4 text-sm text-gray-600">
                          <span className="flex items-center">
                            <Calendar className="h-4 w-4 mr-1" />
                            {new Date(session.date).toLocaleDateString('pt-BR')}
                          </span>
                          {session.duration_minutes && (
                            <span className="flex items-center">
                              <Clock className="h-4 w-4 mr-1" />
                              {session.duration_minutes} min
                            </span>
                          )}
                        </div>
                      </div>
                    </div>
                    <div className="flex items-center space-x-4">
                      <div className="text-right">
                        <div className="flex items-center space-x-6">
                          <div>
                            <p className="text-sm text-gray-600">Precisão</p>
                            <p className="font-semibold text-lg">{session.accuracy?.toFixed(1)}%</p>
                          </div>
                          <div>
                            <p className="text-sm text-gray-600">Acertos</p>
                            <p className="font-semibold text-lg">{session.hits}/{session.shots_fired}</p>
                          </div>
                          <div>
                            <p className="text-sm text-gray-600">Pontuação</p>
                            <p className="font-semibold text-lg">{session.score}</p>
                          </div>
                        </div>
                      </div>
                      <div className="flex space-x-2">
                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={() => setEditingSession(session)}
                        >
                          <Edit className="h-4 w-4" />
                        </Button>
                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={() => handleDeleteSession(session.id)}
                        >
                          <Trash2 className="h-4 w-4 text-red-500" />
                        </Button>
                      </div>
                    </div>
                  </div>
                  {session.notes && (
                    <div className="mt-4 p-3 bg-gray-50 rounded-lg">
                      <p className="text-sm text-gray-700">{session.notes}</p>
                    </div>
                  )}
                </CardContent>
              </Card>
            ))}
          </div>

          {sessions.length === 0 && (
            <div className="text-center py-12">
              <Zap className="h-16 w-16 mx-auto mb-4 text-gray-400" />
              <h3 className="text-lg font-medium text-gray-900 mb-2">Nenhuma sessão encontrada</h3>
              <p className="text-gray-600 mb-4">
                Registre sua primeira sessão de treinamento
              </p>
              <Button onClick={() => setIsAddDialogOpen(true)}>
                <Plus className="h-4 w-4 mr-2" />
                Nova Sessão
              </Button>
            </div>
          )}
        </TabsContent>

        <TabsContent value="statistics" className="space-y-4">
          {/* Statistics by Weapon */}
          <Card>
            <CardHeader>
              <CardTitle>Estatísticas por Arma</CardTitle>
              <CardDescription>Desempenho detalhado por arma utilizada</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {stats.by_weapon?.map((weaponStat, index) => (
                  <div key={index} className="p-4 border rounded-lg">
                    <div className="flex items-center justify-between mb-2">
                      <h4 className="font-semibold">{weaponStat.weapon_name}</h4>
                      <Badge variant="outline">{weaponStat.caliber}</Badge>
                    </div>
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
                      <div>
                        <p className="text-gray-600">Sessões</p>
                        <p className="font-semibold">{weaponStat.sessions}</p>
                      </div>
                      <div>
                        <p className="text-gray-600">Disparos</p>
                        <p className="font-semibold">{weaponStat.shots}</p>
                      </div>
                      <div>
                        <p className="text-gray-600">Precisão</p>
                        <p className="font-semibold">{weaponStat.accuracy}%</p>
                      </div>
                      <div>
                        <p className="text-gray-600">Pontuação Média</p>
                        <p className="font-semibold">{weaponStat.avg_score}</p>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>

      {/* Edit Dialog */}
      {editingSession && (
        <Dialog open={!!editingSession} onOpenChange={() => setEditingSession(null)}>
          <DialogContent className="max-w-2xl">
            <DialogHeader>
              <DialogTitle>Editar Sessão</DialogTitle>
              <DialogDescription>
                Atualize os dados da sessão de treinamento.
              </DialogDescription>
            </DialogHeader>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <Label htmlFor="edit-shots">Disparos</Label>
                <Input
                  id="edit-shots"
                  type="number"
                  value={editingSession.shots_fired}
                  onChange={(e) => setEditingSession({ ...editingSession, shots_fired: parseInt(e.target.value) })}
                />
              </div>
              <div>
                <Label htmlFor="edit-hits">Acertos</Label>
                <Input
                  id="edit-hits"
                  type="number"
                  value={editingSession.hits}
                  onChange={(e) => setEditingSession({ ...editingSession, hits: parseInt(e.target.value) })}
                />
              </div>
              <div>
                <Label htmlFor="edit-score">Pontuação</Label>
                <Input
                  id="edit-score"
                  type="number"
                  step="0.1"
                  value={editingSession.score}
                  onChange={(e) => setEditingSession({ ...editingSession, score: parseFloat(e.target.value) })}
                />
              </div>
              <div>
                <Label htmlFor="edit-duration">Duração (min)</Label>
                <Input
                  id="edit-duration"
                  type="number"
                  value={editingSession.duration_minutes}
                  onChange={(e) => setEditingSession({ ...editingSession, duration_minutes: parseInt(e.target.value) })}
                />
              </div>
              <div className="col-span-2">
                <Label htmlFor="edit-notes">Observações</Label>
                <Textarea
                  id="edit-notes"
                  value={editingSession.notes}
                  onChange={(e) => setEditingSession({ ...editingSession, notes: e.target.value })}
                  rows={3}
                />
              </div>
            </div>
            <div className="flex justify-end space-x-2">
              <Button variant="outline" onClick={() => setEditingSession(null)}>
                Cancelar
              </Button>
              <Button onClick={() => handleEditSession(editingSession)}>
                Salvar
              </Button>
            </div>
          </DialogContent>
        </Dialog>
      )}
    </div>
  )
}

export default Training

