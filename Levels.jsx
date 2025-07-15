import { useState, useEffect } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Progress } from '@/components/ui/progress'
import { Award, TrendingUp, Target, Star, Trophy, Zap } from 'lucide-react'

const Levels = () => {
  const [levels, setLevels] = useState([])
  const [progress, setProgress] = useState(null)
  const [nextLevelInfo, setNextLevelInfo] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchData()
  }, [])

  const fetchData = async () => {
    try {
      // Buscar níveis
      const levelsRes = await fetch('/api/levels')
      const levelsData = await levelsRes.json()
      if (levelsData.success) {
        setLevels(levelsData.data)
      }

      // Buscar progresso do usuário
      const progressRes = await fetch('/api/progress')
      const progressData = await progressRes.json()
      if (progressData.success) {
        setProgress(progressData.data)
      }

      // Buscar informações do próximo nível
      const nextLevelRes = await fetch('/api/progress/next-level')
      const nextLevelData = await nextLevelRes.json()
      if (nextLevelData.success) {
        setNextLevelInfo(nextLevelData.data)
      }
    } catch (error) {
      console.error('Erro ao carregar dados de níveis:', error)
    } finally {
      setLoading(false)
    }
  }

  const updateProgress = async () => {
    try {
      const response = await fetch('/api/progress/update', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
      })
      const data = await response.json()
      if (data.success) {
        fetchData() // Recarregar dados após atualização
      }
    } catch (error) {
      console.error('Erro ao atualizar progresso:', error)
    }
  }

  const getLevelIcon = (order) => {
    switch (order) {
      case 0:
        return <Target className="h-8 w-8" />
      case 1:
        return <Zap className="h-8 w-8" />
      case 2:
        return <Trophy className="h-8 w-8" />
      case 3:
        return <Star className="h-8 w-8" />
      default:
        return <Award className="h-8 w-8" />
    }
  }

  const getLevelColor = (order, isCurrent = false) => {
    if (isCurrent) {
      return 'bg-blue-100 text-blue-800 border-blue-200'
    }
    
    switch (order) {
      case 0:
        return 'bg-gray-100 text-gray-800 border-gray-200'
      case 1:
        return 'bg-green-100 text-green-800 border-green-200'
      case 2:
        return 'bg-yellow-100 text-yellow-800 border-yellow-200'
      case 3:
        return 'bg-purple-100 text-purple-800 border-purple-200'
      default:
        return 'bg-gray-100 text-gray-800 border-gray-200'
    }
  }

  if (loading) {
    return (
      <div className="space-y-6">
        <div className="animate-pulse">
          <div className="h-8 bg-gray-200 rounded w-1/4 mb-6"></div>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {[...Array(4)].map((_, i) => (
              <div key={i} className="h-48 bg-gray-200 rounded-lg"></div>
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
          <h1 className="text-3xl font-bold text-gray-900">Níveis</h1>
          <p className="text-gray-600 mt-1">Acompanhe sua evolução e conquiste novos níveis</p>
        </div>
        <Button onClick={updateProgress} className="bg-blue-600 hover:bg-blue-700">
          <TrendingUp className="h-4 w-4 mr-2" />
          Atualizar Progresso
        </Button>
      </div>

      {/* Current Level Card */}
      {progress && nextLevelInfo && (
        <Card className="bg-gradient-to-r from-blue-50 to-purple-50 border-blue-200">
          <CardHeader>
            <CardTitle className="flex items-center text-2xl">
              <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center mr-4">
                {getLevelIcon(nextLevelInfo.current_level.order)}
              </div>
              Nível Atual: {nextLevelInfo.current_level.name}
            </CardTitle>
            <CardDescription className="text-lg">
              {nextLevelInfo.current_level.message}
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-6">
              {/* Progress to Next Level */}
              {!nextLevelInfo.is_max_level && (
                <div className="space-y-3">
                  <div className="flex justify-between items-center">
                    <span className="text-sm font-medium">
                      Progresso para {nextLevelInfo.next_level.name}
                    </span>
                    <span className="text-sm text-gray-600">
                      {nextLevelInfo.progress_percentage.toFixed(1)}%
                    </span>
                  </div>
                  <Progress value={nextLevelInfo.progress_percentage} className="h-3" />
                  <div className="flex justify-between text-sm text-gray-600">
                    <span>Pontuação atual: {progress.average_score.toFixed(1)}</span>
                    <span>
                      {nextLevelInfo.score_needed > 0 
                        ? `Faltam ${nextLevelInfo.score_needed.toFixed(1)} pontos`
                        : 'Objetivo alcançado!'
                      }
                    </span>
                  </div>
                </div>
              )}

              {nextLevelInfo.is_max_level && (
                <div className="text-center p-6 bg-yellow-50 rounded-lg border border-yellow-200">
                  <Trophy className="h-12 w-12 mx-auto mb-3 text-yellow-600" />
                  <h3 className="text-lg font-semibold text-yellow-800 mb-2">
                    Parabéns! Você atingiu o nível máximo!
                  </h3>
                  <p className="text-yellow-700">
                    Continue treinando para manter sua excelência no tiro esportivo.
                  </p>
                </div>
              )}

              {/* Current Stats */}
              <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                <div className="text-center p-3 bg-white rounded-lg border">
                  <p className="text-2xl font-bold text-blue-600">{progress.total_sessions}</p>
                  <p className="text-sm text-gray-600">Sessões</p>
                </div>
                <div className="text-center p-3 bg-white rounded-lg border">
                  <p className="text-2xl font-bold text-green-600">{progress.overall_accuracy.toFixed(1)}%</p>
                  <p className="text-sm text-gray-600">Precisão</p>
                </div>
                <div className="text-center p-3 bg-white rounded-lg border">
                  <p className="text-2xl font-bold text-orange-600">{progress.average_score.toFixed(1)}</p>
                  <p className="text-sm text-gray-600">Pontuação Média</p>
                </div>
                <div className="text-center p-3 bg-white rounded-lg border">
                  <p className="text-2xl font-bold text-purple-600">{progress.total_shots}</p>
                  <p className="text-sm text-gray-600">Disparos</p>
                </div>
              </div>
            </div>
          </CardContent>
        </Card>
      )}

      {/* All Levels */}
      <div className="space-y-4">
        <h2 className="text-2xl font-bold text-gray-900">Todos os Níveis</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          {levels.map((level) => {
            const isCurrent = progress?.current_level?.id === level.id
            const isAchieved = progress && progress.average_score >= level.min_score
            const isNext = nextLevelInfo?.next_level?.id === level.id
            
            return (
              <Card 
                key={level.id} 
                className={`relative transition-all duration-200 ${
                  isCurrent 
                    ? 'ring-2 ring-blue-500 shadow-lg' 
                    : isAchieved 
                      ? 'border-green-200 bg-green-50' 
                      : ''
                }`}
              >
                <CardHeader>
                  <div className="flex items-center justify-between">
                    <div className="flex items-center space-x-3">
                      <div className={`w-12 h-12 rounded-full flex items-center justify-center ${
                        isCurrent 
                          ? 'bg-blue-100 text-blue-600' 
                          : isAchieved 
                            ? 'bg-green-100 text-green-600'
                            : 'bg-gray-100 text-gray-400'
                      }`}>
                        {getLevelIcon(level.order)}
                      </div>
                      <div>
                        <CardTitle className="flex items-center">
                          {level.name}
                          {isCurrent && (
                            <Badge className="ml-2 bg-blue-100 text-blue-800">
                              Atual
                            </Badge>
                          )}
                          {isNext && !isCurrent && (
                            <Badge variant="outline" className="ml-2">
                              Próximo
                            </Badge>
                          )}
                        </CardTitle>
                        <CardDescription>
                          Pontuação mínima: {level.min_score}
                        </CardDescription>
                      </div>
                    </div>
                    {isAchieved && (
                      <div className="text-green-600">
                        <Award className="h-6 w-6" />
                      </div>
                    )}
                  </div>
                </CardHeader>
                <CardContent>
                  <div className="space-y-3">
                    <p className="text-gray-700">{level.message}</p>
                    
                    {progress && (
                      <div className="space-y-2">
                        <div className="flex justify-between text-sm">
                          <span>Seu progresso:</span>
                          <span className="font-medium">
                            {progress.average_score.toFixed(1)} / {level.min_score}
                          </span>
                        </div>
                        <Progress 
                          value={Math.min(100, (progress.average_score / level.min_score) * 100)} 
                          className="h-2"
                        />
                      </div>
                    )}
                    
                    <div className="flex items-center justify-between pt-2">
                      <Badge 
                        variant="outline" 
                        className={getLevelColor(level.order, isCurrent)}
                      >
                        Nível {level.order}
                      </Badge>
                      {isAchieved ? (
                        <span className="text-sm text-green-600 font-medium">
                          ✓ Conquistado
                        </span>
                      ) : (
                        <span className="text-sm text-gray-500">
                          {level.min_score - (progress?.average_score || 0) > 0 
                            ? `${(level.min_score - (progress?.average_score || 0)).toFixed(1)} pts restantes`
                            : 'Objetivo alcançado'
                          }
                        </span>
                      )}
                    </div>
                  </div>
                </CardContent>
              </Card>
            )
          })}
        </div>
      </div>

      {/* Tips Card */}
      <Card className="bg-gradient-to-r from-green-50 to-blue-50 border-green-200">
        <CardHeader>
          <CardTitle className="flex items-center text-green-800">
            <Target className="h-5 w-5 mr-2" />
            Dicas para Evoluir
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="space-y-2 text-green-700">
            <p>• Pratique regularmente para manter a consistência</p>
            <p>• Registre todas as suas sessões de treinamento</p>
            <p>• Foque na precisão antes de aumentar a velocidade</p>
            <p>• Analise suas estatísticas para identificar pontos de melhoria</p>
            <p>• Participe de competições para ganhar experiência</p>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}

export default Levels

