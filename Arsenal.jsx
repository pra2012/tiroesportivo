import { useState, useEffect } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogTrigger } from '@/components/ui/dialog'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Target, Plus, Search, Filter, Edit, Trash2 } from 'lucide-react'

const Arsenal = () => {
  const [weapons, setWeapons] = useState([])
  const [filteredWeapons, setFilteredWeapons] = useState([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [filterCaliber, setFilterCaliber] = useState('all')
  const [filterOwner, setFilterOwner] = useState('all')
  const [isAddDialogOpen, setIsAddDialogOpen] = useState(false)
  const [editingWeapon, setEditingWeapon] = useState(null)
  const [newWeapon, setNewWeapon] = useState({
    name: '',
    caliber: '',
    owner: ''
  })

  const calibers = ['.22LR', '9mm', '.38SPL', '.45', '.380']
  const owners = ['Old', 'Fer', 'JST', 'Dra', 'Mig', 'Tex', 'CTJ']

  useEffect(() => {
    fetchWeapons()
  }, [])

  useEffect(() => {
    filterWeapons()
  }, [weapons, searchTerm, filterCaliber, filterOwner])

  const fetchWeapons = async () => {
    try {
      const response = await fetch('/api/weapons')
      const data = await response.json()
      if (data.success) {
        setWeapons(data.data)
      }
    } catch (error) {
      console.error('Erro ao carregar armas:', error)
    } finally {
      setLoading(false)
    }
  }

  const filterWeapons = () => {
    let filtered = weapons

    if (searchTerm) {
      filtered = filtered.filter(weapon =>
        weapon.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        weapon.caliber.toLowerCase().includes(searchTerm.toLowerCase()) ||
        weapon.owner.toLowerCase().includes(searchTerm.toLowerCase())
      )
    }

    if (filterCaliber !== 'all') {
      filtered = filtered.filter(weapon => weapon.caliber === filterCaliber)
    }

    if (filterOwner !== 'all') {
      filtered = filtered.filter(weapon => weapon.owner === filterOwner)
    }

    setFilteredWeapons(filtered)
  }

  const handleAddWeapon = async () => {
    try {
      const response = await fetch('/api/weapons', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(newWeapon),
      })
      const data = await response.json()
      if (data.success) {
        setWeapons([...weapons, data.data])
        setNewWeapon({ name: '', caliber: '', owner: '' })
        setIsAddDialogOpen(false)
      }
    } catch (error) {
      console.error('Erro ao adicionar arma:', error)
    }
  }

  const handleEditWeapon = async (weapon) => {
    try {
      const response = await fetch(`/api/weapons/${weapon.id}`, {
        method: 'PUT',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(weapon),
      })
      const data = await response.json()
      if (data.success) {
        setWeapons(weapons.map(w => w.id === weapon.id ? data.data : w))
        setEditingWeapon(null)
      }
    } catch (error) {
      console.error('Erro ao editar arma:', error)
    }
  }

  const handleDeleteWeapon = async (weaponId) => {
    if (confirm('Tem certeza que deseja excluir esta arma?')) {
      try {
        const response = await fetch(`/api/weapons/${weaponId}`, {
          method: 'DELETE',
        })
        const data = await response.json()
        if (data.success) {
          setWeapons(weapons.filter(w => w.id !== weaponId))
        }
      } catch (error) {
        console.error('Erro ao excluir arma:', error)
      }
    }
  }

  if (loading) {
    return (
      <div className="space-y-6">
        <div className="animate-pulse">
          <div className="h-8 bg-gray-200 rounded w-1/4 mb-6"></div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {[...Array(6)].map((_, i) => (
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
          <h1 className="text-3xl font-bold text-gray-900">Arsenal</h1>
          <p className="text-gray-600 mt-1">Gerencie seu acervo de armas</p>
        </div>
        <Dialog open={isAddDialogOpen} onOpenChange={setIsAddDialogOpen}>
          <DialogTrigger asChild>
            <Button className="bg-blue-600 hover:bg-blue-700">
              <Plus className="h-4 w-4 mr-2" />
              Adicionar Arma
            </Button>
          </DialogTrigger>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Adicionar Nova Arma</DialogTitle>
              <DialogDescription>
                Preencha os dados da nova arma para adicionar ao seu arsenal.
              </DialogDescription>
            </DialogHeader>
            <div className="space-y-4">
              <div>
                <Label htmlFor="name">Nome/Modelo</Label>
                <Input
                  id="name"
                  value={newWeapon.name}
                  onChange={(e) => setNewWeapon({ ...newWeapon, name: e.target.value })}
                  placeholder="Ex: Glock 17"
                />
              </div>
              <div>
                <Label htmlFor="caliber">Calibre</Label>
                <Select value={newWeapon.caliber} onValueChange={(value) => setNewWeapon({ ...newWeapon, caliber: value })}>
                  <SelectTrigger>
                    <SelectValue placeholder="Selecione o calibre" />
                  </SelectTrigger>
                  <SelectContent>
                    {calibers.map(caliber => (
                      <SelectItem key={caliber} value={caliber}>{caliber}</SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div>
                <Label htmlFor="owner">Proprietário</Label>
                <Select value={newWeapon.owner} onValueChange={(value) => setNewWeapon({ ...newWeapon, owner: value })}>
                  <SelectTrigger>
                    <SelectValue placeholder="Selecione o proprietário" />
                  </SelectTrigger>
                  <SelectContent>
                    {owners.map(owner => (
                      <SelectItem key={owner} value={owner}>{owner}</SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div className="flex justify-end space-x-2">
                <Button variant="outline" onClick={() => setIsAddDialogOpen(false)}>
                  Cancelar
                </Button>
                <Button onClick={handleAddWeapon} disabled={!newWeapon.name || !newWeapon.caliber || !newWeapon.owner}>
                  Adicionar
                </Button>
              </div>
            </div>
          </DialogContent>
        </Dialog>
      </div>

      {/* Filters */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center">
            <Filter className="h-5 w-5 mr-2" />
            Filtros
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
            <div>
              <Label htmlFor="search">Buscar</Label>
              <div className="relative">
                <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
                <Input
                  id="search"
                  className="pl-10"
                  placeholder="Nome, calibre ou proprietário..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                />
              </div>
            </div>
            <div>
              <Label htmlFor="caliber-filter">Calibre</Label>
              <Select value={filterCaliber} onValueChange={setFilterCaliber}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">Todos os calibres</SelectItem>
                  {calibers.map(caliber => (
                    <SelectItem key={caliber} value={caliber}>{caliber}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div>
              <Label htmlFor="owner-filter">Proprietário</Label>
              <Select value={filterOwner} onValueChange={setFilterOwner}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">Todos os proprietários</SelectItem>
                  {owners.map(owner => (
                    <SelectItem key={owner} value={owner}>{owner}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Weapons Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredWeapons.map((weapon) => (
          <Card key={weapon.id} className="hover:shadow-lg transition-shadow">
            <CardHeader>
              <div className="flex items-center justify-between">
                <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                  <Target className="h-6 w-6 text-blue-600" />
                </div>
                <div className="flex space-x-1">
                  <Button
                    variant="ghost"
                    size="icon"
                    onClick={() => setEditingWeapon(weapon)}
                  >
                    <Edit className="h-4 w-4" />
                  </Button>
                  <Button
                    variant="ghost"
                    size="icon"
                    onClick={() => handleDeleteWeapon(weapon.id)}
                  >
                    <Trash2 className="h-4 w-4 text-red-500" />
                  </Button>
                </div>
              </div>
              <CardTitle className="text-lg">{weapon.name}</CardTitle>
              <CardDescription>Proprietário: {weapon.owner}</CardDescription>
            </CardHeader>
            <CardContent>
              <div className="space-y-2">
                <Badge variant="secondary" className="bg-orange-100 text-orange-800">
                  {weapon.caliber}
                </Badge>
                <p className="text-sm text-gray-600">
                  Adicionado em {new Date(weapon.created_at).toLocaleDateString('pt-BR')}
                </p>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      {filteredWeapons.length === 0 && (
        <div className="text-center py-12">
          <Target className="h-16 w-16 mx-auto mb-4 text-gray-400" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">Nenhuma arma encontrada</h3>
          <p className="text-gray-600 mb-4">
            {weapons.length === 0 
              ? 'Adicione sua primeira arma ao arsenal'
              : 'Tente ajustar os filtros de busca'
            }
          </p>
          {weapons.length === 0 && (
            <Button onClick={() => setIsAddDialogOpen(true)}>
              <Plus className="h-4 w-4 mr-2" />
              Adicionar Primeira Arma
            </Button>
          )}
        </div>
      )}

      {/* Edit Dialog */}
      {editingWeapon && (
        <Dialog open={!!editingWeapon} onOpenChange={() => setEditingWeapon(null)}>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Editar Arma</DialogTitle>
              <DialogDescription>
                Atualize os dados da arma.
              </DialogDescription>
            </DialogHeader>
            <div className="space-y-4">
              <div>
                <Label htmlFor="edit-name">Nome/Modelo</Label>
                <Input
                  id="edit-name"
                  value={editingWeapon.name}
                  onChange={(e) => setEditingWeapon({ ...editingWeapon, name: e.target.value })}
                />
              </div>
              <div>
                <Label htmlFor="edit-caliber">Calibre</Label>
                <Select value={editingWeapon.caliber} onValueChange={(value) => setEditingWeapon({ ...editingWeapon, caliber: value })}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {calibers.map(caliber => (
                      <SelectItem key={caliber} value={caliber}>{caliber}</SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div>
                <Label htmlFor="edit-owner">Proprietário</Label>
                <Select value={editingWeapon.owner} onValueChange={(value) => setEditingWeapon({ ...editingWeapon, owner: value })}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {owners.map(owner => (
                      <SelectItem key={owner} value={owner}>{owner}</SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div className="flex justify-end space-x-2">
                <Button variant="outline" onClick={() => setEditingWeapon(null)}>
                  Cancelar
                </Button>
                <Button onClick={() => handleEditWeapon(editingWeapon)}>
                  Salvar
                </Button>
              </div>
            </div>
          </DialogContent>
        </Dialog>
      )}
    </div>
  )
}

export default Arsenal

