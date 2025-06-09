
# Contrato de Subasta en Solidity

Este repositorio contiene el contrato inteligente `Auction.sol`, desarrollado para manejar una subasta con las siguientes características:

## 🧩 Funcionalidades

### 🏗 Constructor
- Inicializa la subasta con una duración en segundos.
- Registra al `owner` del contrato.

### 🔨 Función `bid()`
- Permite realizar ofertas siempre que:
  - La subasta esté activa.
  - La nueva oferta supere en al menos un 5% la mejor oferta actual.
- Extiende la subasta 10 minutos si la oferta entra en los últimos 10 minutos.

### 🏆 Función `showWinner()`
- Devuelve el ganador y su oferta, solo si la subasta ha terminado.

### 📄 Función `showOffers()`
- Muestra todas las ofertas realizadas.

### 💸 Función `refund()`
- Solo accesible por el `owner`, al finalizar la subasta.
- Devuelve los depósitos a todos los oferentes no ganadores, reteniendo una comisión del 2%.

### 💰 Función `partialRefund()`
- Permite a los participantes recuperar lo ofertado por encima de su última oferta válida.

### 🛡 Modificadores
- `onlyOwner`: restringe funciones al dueño.
- `isActive`: asegura que la subasta esté activa.

### ⚠ Seguridad
- Usa `receive()` para evitar transferencias accidentales fuera de `bid()`.

## 🧪 Cómo probar

1. **Deploy:** El constructor requiere una duración en segundos (por ejemplo, `3600` para 1 hora).
2. **Ofertar:** Llamar a `bid()` desde distintas cuentas con montos válidos.
3. **Ver Ofertas:** Usar `showOffers()` para confirmar.
4. **Ver Ganador:** Llamar a `showWinner()` cuando finalice la subasta.
5. **Reembolsos:** 
   - `partialRefund()` para ofertas múltiples.
   - `refund()` debe ser ejecutado por el `owner`.

## ⏲ Tiempo real de finalización
- Fin estimado (UTC): `2025-06-09 01:11:44 UTC`
- Timestamp: `1749431504`

---

## 📄 Licencia
MIT
