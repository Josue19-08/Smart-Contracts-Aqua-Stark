# Sepolia Deployment Guide

## Quick Deploy (si ya tienes .env configurado)

```bash
sozo build --profile sepolia
sozo migrate --profile sepolia
```

## Setup Inicial (primera vez)

### 1. Crear cuenta Sepolia
- Instala [Argent X](https://www.argent.xyz/argent-x/) o [Braavos](https://braavos.app/)
- Cambia a red "Sepolia Testnet"
- Crea cuenta y exporta: **Address** y **Private Key**

### 2. Obtener STRK para gas
- [Starknet Faucet](https://starknet-faucet.vercel.app/)

### 3. Configurar .env
```bash
cp .env.md .env
# Edita .env con tus credenciales reales
```

### 4. Crear dojo_sepolia.toml
```toml
[world]
name = "Aqua Stark"
description = "Aqua Stark Game World - Sepolia Testnet"
seed = "aqua-stark-sepolia"

[env]
rpc_url = "https://api.cartridge.gg/x/starknet/sepolia"
account_address = "TU_ADDRESS"
private_key = "TU_PRIVATE_KEY"
# world_address = ""  # Dejar comentado para deploy nuevo

[namespace]
default = "aqua_stark_0_0_1"

[writers]
"aqua_stark_0_0_1" = [
    "aqua_stark_0_0_1-PlayerSystem",
    "aqua_stark_0_0_1-FishSystem",
    "aqua_stark_0_0_1-TankSystem",
    "aqua_stark_0_0_1-DecorationSystem"
]

[migration]
order_inits = [
    "aqua_stark_0_0_1-PlayerSystem",
    "aqua_stark_0_0_1-FishSystem",
    "aqua_stark_0_0_1-TankSystem",
    "aqua_stark_0_0_1-DecorationSystem"
]
```

## Deploy Actual (2025-12-31)

**World:** `0x01100e97a165924b38e23f034e5e35cbb72e0b675c3d7dffc2244c45b5441f36`

| Contract | Address |
|----------|---------|
| PlayerSystem | `0x0429a924f249b0ab1773076a8d600a898855eafe5c903743d2c2e564ef3a33e1` |
| FishSystem | `0x033f2f6c78702297d347b872e7963c4c79e5dfb8dbc4d887d77b47ef599444ca` |
| TankSystem | `0x07d6a9f6a46f7376fa3f5539ba0cec03e5c68e301eed7ecb9e37676ab48824a5` |
| DecorationSystem | `0x0566f4d2d1687af6e20534d3b5cfc7a90bb734b0aeb575ca9264fd36362971f0` |

[Ver en Starkscan](https://sepolia.starkscan.co/contract/0x01100e97a165924b38e23f034e5e35cbb72e0b675c3d7dffc2244c45b5441f36)

## Comandos Útiles

```bash
# Verificar deployment
sozo inspect --profile sepolia

# Ejecutar función (ejemplo: registrar player)
sozo execute --profile sepolia aqua_stark_0_0_1-PlayerSystem register_player

# Ver estado del world
sozo inspect --profile sepolia
```

## Re-deploy (después de cambios)

Si cambias el código y quieres actualizar:

```bash
# 1. Build
sozo build --profile sepolia

# 2. Migrate (actualiza contratos existentes)
sozo migrate --profile sepolia
```

**Nota:** Si cambias el `seed` en dojo_sepolia.toml, se creará un World nuevo.
