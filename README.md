# 🏦 KipuBankV2

KipuBankV2 es una versión extendida y más cercana a producción del contrato original KipuBank. Permite a los usuarios depositar y retirar ETH y tokens ERC-20 en bóvedas personales, con límites globales expresados en USD gracias a la integración con Chainlink. El contrato incorpora control de acceso, contabilidad multi-token, conversión de decimales, y mejoras de seguridad y eficiencia.

---

## 🚀 Contrato desplegado

- **Dirección:** `0xAFF4d537F30ac085f9f9399a181450eDadd1A88e`
- **Red:** Sepolia Testnet
- **Verificado en Etherscan:** [Ver contrato en Sepolia](https://sepolia.etherscan.io/address/0xAFF4d537F30ac085f9f9399a181450eDadd1A88e#code)

---

## 🔧 Mejoras realizadas

- **Control de acceso:** Uso de `AccessControl` de OpenZeppelin para roles administrativos.
- **Soporte multi-token:** Depósitos y retiros en ETH y cualquier token ERC-20.
- **Contabilidad interna:** Mappings anidados para gestionar saldos por usuario y por token.
- **Oráculo Chainlink:** Conversión de ETH a USD usando `AggregatorV3Interface`.
- **Límite global en USD:** Cap total de depósitos expresado en dólares (BANK_CAP_USD).
- **Conversión de decimales:** Normalización de activos a 6 decimales (estándar USDC).
- **Seguridad y eficiencia:** Uso de `call()` seguro, patrón checks-effects-interactions, variables `constant` e `immutable`.

---

## 🧠 Funcionalidades

- Depósitos en ETH (`depositETH`) y ERC-20 (`depositToken`)
- Retiros en ETH (`withdrawETH`) y ERC-20 (`withdrawToken`)
- Validación de límite global en USD
- Consulta de saldos por usuario y token
- Emisión de eventos en cada operación
- Errores personalizados para debugging

---

## 🔐 Seguridad aplicada

- Roles con `AccessControl` (`ADMIN_ROLE`)
- Validación de límite global con oráculo Chainlink
- Transferencias ETH con `call` y chequeo de éxito
- Transferencias ERC-20 con `transferFrom` y `transfer`
- Patrón checks-effects-interactions
- Comentarios NatSpec en funciones, errores y eventos

---

## 🛠️ Despliegue del contrato

1. Abrí Remix IDE
2. Pegá el código en `src/KipuBankV2.sol`
3. Compilá con versión `0.8.20` y optimización activada
4. Conectá MetaMask en red Sepolia
5. En “Deploy & Run Transactions”, seleccioná `Injected Provider - MetaMask`
6. Ingresá el parámetro del constructor:
   - `priceFeed`: `0x694AA1769357215DE4FAC081bf1f309aDC325306` (ETH/USD en Sepolia)
7. Hacé clic en “Deploy” y confirmá en MetaMask

---

## 🧾 Verificación del contrato en Etherscan

Antes de verificar el contrato, es necesario realizar el **flattening** para incluir todas las dependencias (OpenZeppelin, Chainlink, etc.) en un solo archivo. Esto se debe a que Etherscan no admite `import` externos.

### 🔧 Pasos para hacer el flattening y verificar:

1. En Remix IDE, hacé clic derecho sobre `KipuBankV2.sol` y seleccioná **“Flatten”**
   - Si no aparece la opción, activá el plugin **Flattener** desde el ícono de puzzle 🧩 (Plugin Manager)
2. Se generará un nuevo archivo con todo el código inline (sin imports)
3. Copiá el contenido del archivo flatten
4. Abrí [Sepolia Etherscan - Verify](https://sepolia.etherscan.io/verifyContract)
5. Pegá el código flatten en el formulario
6. Completá los campos:
   - **Compiler Type:** Solidity (Single file)
   - **Compiler Version:** `v0.8.20+commit.a1b79de6`
   - **License:** MIT
7. Hacé clic en **Verify and Publish**

---

## 🔄 Interacción con el contrato

### Desde Remix

- `depositETH()` → Enviá ETH usando el campo “Value”
- `depositToken(address,uint256)` → Depositá tokens ERC-20
- `withdrawETH(uint256)` → Retirá ETH
- `withdrawToken(address,uint256)` → Retirá tokens ERC-20
- `getTotalUSD()` → Consultá el valor total depositado en USD

### Desde Etherscan

- Abrí la pestaña “Write Contract”
- Conectá MetaMask
- Usá las funciones disponibles para interactuar

---

## 📂 Estructura del repositorio

KipuBankV2/ 
├── src/ 
│ └── KipuBankV2.sol 
├── README.md


---

## ✨ Créditos

Desarrollado por Juan Duarte como parte del curso ETH Kipu — Talento Tech 2025.
