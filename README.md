# Roblox Combat Scripts

Módulos de combate desenvolvidos para Roblox em Luau, focados em sistema de habilidades com respirações (breathing styles).

## Módulos

| Arquivo | Descrição |
|---|---|
| `WaterSlashModule.lua` | Skill de slash simples da respiração da água |
| `WaterDualSlashModule.lua` | Skill de slash duplo com dois efeitos sequenciais |
| `BreathingStatus.lua` | Gerencia os stats de cada estilo de respiração |
| `JumpHitService.lua` | Skill de ataque aéreo com queda |

## Funcionalidades

- Hitbox via RaycastHitbox
- Sistema de parry e bloqueio
- Stun handler integrado
- LinearVelocity para movimentação durante skills
- Interrupção automática por stun
- Efeitos sincronizados via RemoteEvent

## Dependências

- RaycastHitboxV4
- BlockingModule
- StunHandlerV2
- BreathingStatus
- AnimationStopper
