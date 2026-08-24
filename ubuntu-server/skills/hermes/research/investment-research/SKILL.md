---
name: investment-research
description: "Research and analyze investment opportunities across all asset classes, capital tiers, and platforms. Covers traditional markets, alternatives, crypto, fractional ownership, and automation with n8n + Hermes. Peru/LatAm specific context included."
version: 1.0.0
author: Hermes Agent
tags: [investing, portfolio, automation, n8n, research, finance, platforms, crypto, real-estate, startups, fixed-income, polymarket, latam, peru]
metadata:
  hermes:
    tags: [investing, research, portfolio, automation, n8n]
---

# Investment Research & Automation

Comprehensive investment research and automation skill. Covers all asset classes, platforms, capital tiers, and n8n + Hermes integration for portfolio monitoring and alerting.

## When to Use

Load when the user asks about:
- Investing, investment platforms, "en qué invertir", "dónde poner plata"
- Comparing asset classes by capital level
- Setting up portfolio tracking automation
- Stock/crypto/real estate/startup/alternative investment research
- n8n workflows for investors
- Peru/LatAm specific investment instruments
- Portfolio allocation strategies

## Core Principles

- **Platform-first**: Always match capital amount to specific platforms with minimums
- **Real numbers**: Use verified platform data from research (see references/investment-platforms-2026.md)
- **Risk-appropriate**: Match to user risk tolerance and time horizon
- **Automation-forward**: Whenever relevant, show how n8n + Hermes can automate monitoring
- **LatAm-aware**: Include Peru-specific options (BVL, trii, fondos mutuos, bonos BCRP)

## Capital Tier Framework

| Tier | Range (PEN) | Range (USD) | Best Instruments |
|------|-------------|-------------|------------------|
| Micro | S/ 10-500 | $3-130 | Fractional shares, pooled RE funds, music royalties, DCA crypto, Mintos P2P, Polymarket |
| Small | S/ 500-5K | $130-1.3K | RE crowdfunding, startup equity (Reg CF), fine art fractional, Peruvian stocks/BVL |
| Medium | S/ 5K-50K | $1.3K-13K | Private equity funds, multi-asset alts, SPV angel investing, tokenized RE |
| Large | S/ 50K+ | $13K+ | Direct RE, VC funds, farmland, government bonds, traditional PE |

## n8n Automation Patterns

### Existing templates to leverage:
- Portfolio risk: n8n workflow #12487 (Google Sheets + Alpha Vantage)
- Multi-broker tracker: n8n workflow #6317 (Google Sheets + Telegram)
- Daily stock AI: n8n workflow #15670 (Google Sheets + RSS + Groq LLM + Gmail)
- Real smart alerts: n8n workflow #7701 (Indian+US market email + Telegram)
- AI trading: n8n workflow #5711 (Alpaca + Google Sheets)
- Commodity monitor: n8n workflow #15333 (Google Sheets + Gemini AI + Gmail)

### Custom workflows to build:
1. Polymarket Opportunity Detector (Polymarket API → n8n → Hermes analysis → WhatsApp)
2. Multi-Asset Portfolio Dashboard (Alpha Vantage + CoinGecko → n8n → daily WhatsApp briefing)
3. Startup Deal Screener (Wefunder/Republic scraper → Hermes scoring → Notion)
4. Crypto Whale Tracker (Apify Polymarket + Etherscan → n8n alerts)
5. LatAm Fixed Income Rate Monitor (BCRP/SBS scraping → cross-country comparison → alerts)

## Free APIs for Automation

| API | Free Tier | Coverage |
|-----|----------|----------|
| Alpha Vantage | 25/day | Stocks, forex, crypto — beginner-friendly |
| Twelve Data | 800/day | Stocks, forex, crypto, ETFs |
| Polygon.io | 5/min unlimited | US stocks/options/forex/crypto — real-time |
| Finnhub | 60/min | US stocks, forex, crypto + news |
| CoinGecko | 30/min (public) | 13K+ coins |
| Polymarket | Public (no key) | Prediction markets |
| Alpaca | Unlimited (paper) | US stocks + trading |

## Peru-Specific Investment Options (2026)

- **tríi**: Digital bag broker app, lowest commissions, S/ 100 minimums, access to BVL and US ETFs
- **ViaBCP**: Mutual funds from Banco de Crédito (5% capital gains tax for Peruvians)
- **Depósitos a Plazo**: 5-6% E.A. at financieras, slightly lower at major banks
- **Bonos Soberanos**: Peru 4-year bond at 6.5% coupon (April 2026 emission)
- **Colombian CDT**: Up to 13.51% E.A. at MPF Invest — cross-border opportunity
- **Factoring/Crowdlending**: Aflore, Prestamype (emerging)

## Pitfalls & Rules

### Do
- Match capital amount to appropriate platforms
- Show real minimums from research data, not estimates
- Include Peru/LatAm options when relevant
- Suggest automation workflows where applicable
- Treat user as serious investor, not beginner

### Do NOT
- Recommend anything without verifying it's still active in 2026
- Use outdated platform names abandoned
- Ignore the user's actual available capital as a constraint
- Push crypto over traditional options unless asked

## References

- **references/investment-platforms-2026.md**: Full database of investment platforms with minimums, returns, risks by capital tier. Financial data APIs, n8n workflows, Peru-specific notes, portfolio allocation models, and automation architecture.