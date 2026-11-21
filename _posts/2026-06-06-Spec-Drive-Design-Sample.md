---
layout: post
title: KNN Stock Prediction System
subtitle: Complete Technical Guide
cover-img: /assets/img/header/2026-05-14/CEREBRAS.jpeg
thumbnail-img: /assets/img/thumb.png
share-img: /assets/img/header/2026-05-14/CEREBRAS.jpeg
published: false
pinned: true
mathjax: true
tags: [draft, SDD]
---


# A Spec Drive Design Sample 
This is a sample document to present the AI coding agent accept SDD document. 
 

---
# KNN Stock Prediction System - Complete Technical Guide

## 📊 System Overview

This is an advanced **K-Nearest Neighbors (KNN) Stock Prediction System** that combines machine learning with traditional technical analysis to provide trading insights. The system uses Flask for the web interface and integrates multiple analytical approaches for comprehensive market analysis.

### Key Technologies Used
- **Flask**: Web framework for the backend API
- **yfinance**: Real-time stock data fetching
- **pandas/numpy**: Data manipulation and numerical computations  
- **matplotlib**: Chart generation and visualization
- **KNN Algorithm**: Machine learning for pattern recognition

---

## 🤖 Core Algorithm: K-Nearest Neighbors (KNN)

### What is KNN?
K-Nearest Neighbors is a **non-parametric machine learning algorithm** that makes predictions based on the similarity of current conditions to historical patterns. In stock prediction:

1. **Pattern Matching**: Finds historical periods with similar market conditions
2. **Weighted Decisions**: Uses the k most similar periods to make predictions
3. **Adaptive Learning**: Automatically adjusts to changing market conditions

### How KNN Works in This System

```python
def calculate_knn_ma(self, price_series, target_series, n_neighbors=3, window_size=50):
    """Calculate KNN-based moving average"""
    for i in range(len(price_series)):
        current_target = target_series.iloc[i]  # Current market condition
        
        # Find historical similar conditions
        distances = np.abs(hist_targets - current_target)
        
        # Select k nearest neighbors
        closest_indices = distances.nsmallest(n_neighbors).index
        knn_mean = hist_values.loc[closest_indices].mean()
```

**Key Parameters:**
- `n_neighbors=3`: Uses 3 most similar historical periods
- `window_size=50`: Analyzes last 50 periods for comparison
- `target_series`: Reference metric (5-period SMA) for similarity matching

---

## 📈 Technical Indicators Integration

### 1. KNN Moving Average
- **Purpose**: Dynamic trend line that adapts to market patterns
- **Calculation**: Weighted average of prices from periods with similar market conditions
- **Advantage**: More responsive than traditional moving averages during trend changes

### 2. Bollinger Bands
```python
def calculate_bollinger_bands(self, period=14, std_multiplier=2.0):
    basis = close.rolling(window=period).mean()  # Middle line (SMA)
    std = close.rolling(window=period).std()     # Standard deviation
    
    upper = basis + (std * std_multiplier)       # Upper band (+2σ)
    lower = basis - (std * std_multiplier)       # Lower band (-2σ)
```

**Trading Signals:**
- **Overbought**: Price above upper band
- **Oversold**: Price below lower band
- **Volatility**: Band width indicates market volatility

### 3. RSI (Relative Strength Index)
```python
def calculate_rsi(self, period=14):
    delta = close.diff()
    gain = (delta.where(delta > 0, 0)).rolling(window=period).mean()
    loss = (-delta.where(delta < 0, 0)).rolling(window=period).mean()
    
    rs = gain / loss
    rsi = 100 - (100 / (1 + rs))
```

**Interpretation:**
- **RSI > 70**: Overbought condition (potential sell signal)
- **RSI < 30**: Oversold condition (potential buy signal)
- **RSI ≈ 50**: Neutral momentum

### 4. ATR (Average True Range)
```python
def calculate_atr(self, period=14):
    tr1 = high - low                    # High-Low range
    tr2 = abs(high - close.shift())     # High-Previous Close
    tr3 = abs(low - close.shift())      # Low-Previous Close
    
    true_range = max(tr1, tr2, tr3)     # True Range
    atr = true_range.rolling(window=period).mean()  # ATR
```

**Applications:**
- **Volatility Measurement**: Higher ATR = more volatile stock
- **Stop-Loss Placement**: Set stops at 1-2x ATR from entry
- **Profit Targets**: Target 1-3x ATR moves

### 5. ZigZag Indicator
```python
def calculate_zigzag(self, depth=12, deviation=5, backstep=2):
    # Identifies significant highs and lows
    # Filters out noise by requiring minimum deviation percentage
    # Helps identify trend reversals and major support/resistance levels
```

**Purpose:**
- **Trend Identification**: Connects major highs and lows
- **Noise Filtering**: Ignores minor price fluctuations
- **Pattern Recognition**: Helps identify chart patterns

---

## 🎯 Granville's 8 Trading Rules

The system implements **Joseph Granville's 8 Rules** for moving average trading:

### Buy Signals (B1-B4)
1. **B1 - Breakthrough**: Price breaks above rising moving average
2. **B2 - False Break Recovery**: Price bounces back above MA after brief dip
3. **B3 - Pullback Hold**: Price pulls back to rising MA but holds above
4. **B4 - Oversold Bounce**: Price bounces from significantly below MA

### Sell Signals (S5-S8)
5. **S5 - MA Breakdown**: Price breaks below falling moving average
6. **S6 - False Break Failure**: Price fails to hold above MA after brief rally
7. **S7 - Rally Failure**: Price fails to reach falling MA
8. **S8 - Overbought Reversal**: Price reverses from significantly above MA

```python
def identify_granville_signals(self, knn_ma, bb_basis, bb_upper, bb_lower):
    # B1: Breakthrough
    if (close.iloc[i-1] < knn_ma.iloc[i-1] and close.iloc[i] > knn_ma.iloc[i] and
        knn_ma.iloc[i] > knn_ma.iloc[i-1]):
        signals.iloc[i] = 'B1_Breakthrough'
    
    # S5: MA break down
    elif (close.iloc[i-1] > knn_ma.iloc[i-1] and close.iloc[i] < knn_ma.iloc[i] and
          knn_ma.iloc[i] < knn_ma.iloc[i-1]):
        signals.iloc[i] = 'S5_MA_Breakdown'
```

---

## 🔍 KNN Prediction Algorithm

### Pattern Matching Process

```python
def calculate_knn_prediction(self, knn_ma, smoothing_period=50):
    for i in range(len(knn_ma)):
        current_price = knn_ma.iloc[i]
        pos_count = 0  # Positive trend count
        neg_count = 0  # Negative trend count
        
        # Analyze last 10 periods for similar patterns
        for j in range(1, min(11, i+1)):
            hist_price = knn_ma.iloc[i-j]
            
            # Trend detection
            if i-j-1 >= 0:
                prev_price = knn_ma.iloc[i-j-1]
                if hist_price > prev_price:
                    pos_count += 1  # Uptrend
                else:
                    neg_count += 1  # Downtrend
        
        # Generate prediction signal
        prediction = 1 if pos_count > neg_count else -1
```

**Prediction Interpretation:**
- **+1**: Bullish prediction (expect price increase)
- **-1**: Bearish prediction (expect price decrease)
- **Smoothing**: 3-period rolling average reduces noise

---

## 📊 Signal Generation & Trading Logic

### Multi-Factor Analysis
The system combines multiple indicators for robust signal generation:

```python
# Calculate recommendation
signals_count = 0
if current_signals['price'] > current_signals['knn_ma']:
    signals_count += 1  # Price above KNN MA (bullish)
if current_signals['rsi'] < 70:
    signals_count += 1  # RSI not overbought
if current_signals['knn_prediction'] > 0:
    signals_count += 1  # KNN prediction bullish
if current_signals['price'] > current_signals['bb_basis']:
    signals_count += 1  # Price above BB middle line

# Generate final recommendation
if signals_count >= 3:
    recommendation = "BULLISH BIAS"
elif signals_count <= 1:
    recommendation = "BEARISH BIAS"
else:
    recommendation = "NEUTRAL"
```

### Signal Strength Scoring
- **4/4 Signals**: Strong conviction
- **3/4 Signals**: Moderate conviction  
- **2/4 Signals**: Neutral/mixed signals
- **1/4 Signals**: Weak counter-trend

---

## 🎨 Visualization System

### Main Chart Features
1. **Candlestick/OHLC Bars**: Price action visualization
2. **Bollinger Bands**: Volatility bands with fill
3. **KNN Moving Average**: Color-coded trend line
4. **Trading Signals**: Buy (B) and Sell (S) markers
5. **Dark Theme**: Professional trading interface

### Detailed Analysis Charts
1. **ATR Ranges**: Volatility-based price targets
2. **RSI Oscillator**: Momentum analysis with overbought/oversold levels
3. **KNN Prediction**: Signal strength over time

```python
def generate_chart(self, results, chart_type='main'):
    plt.style.use('dark_background')  # Professional dark theme
    
    # Candlestick rendering
    for i in range(len(self.data)):
        color = 'lime' if close_price >= open_price else 'red'
        ax.plot([i, i], [low_price, high_price], color=color)
        ax.bar(i, body_height, bottom=body_bottom, color=color)
    
    # Signal markers
    for idx, row in granville_signals.iterrows():
        if row['signal_strength'] == 1:  # Buy signals
            ax.scatter(i, price, color='lime', marker='s', s=150)
            ax.text(i, price, 'B', ha='center', va='center')
```

---

## ⚙️ System Architecture

### Flask Web Framework
```python
@app.route('/api/analyze', methods=['POST'])
def analyze():
    # 1. Parse request parameters
    symbol = data.get('symbol', 'AAPL').upper()
    period = data.get('period', '6mo')
    
    # 2. Initialize trading system
    system = AdvancedTradingSystem(symbol=symbol, period=period)
    
    # 3. Run analysis
    results = system.run_analysis()
    
    # 4. Generate charts and signals
    current_signals = system.get_current_signals(results)
    main_chart = system.generate_chart(results, 'main')
    
    # 5. Return JSON response
    return jsonify({
        'current_signals': current_signals,
        'recommendation': recommendation,
        'main_chart': main_chart
    })
```

### Data Flow
1. **Data Fetching**: yfinance → pandas DataFrame
2. **Preprocessing**: Calculate hl2, handle missing values
3. **Analysis**: Run all indicators and KNN algorithms
4. **Signal Generation**: Combine multiple factors
5. **Visualization**: Generate charts as base64 images
6. **API Response**: JSON with analysis results

### Thread Safety
```python
plot_lock = Lock()  # Prevents matplotlib threading issues

def generate_chart(self, results, chart_type='main'):
    with plot_lock:  # Thread-safe chart generation
        # Chart creation code
```

---

## 🔧 Configuration Parameters

### KNN Algorithm Settings
```python
# KNN Moving Average
n_neighbors=3        # Number of similar periods to analyze
window_size=50       # Historical lookback period
smoothing_period=50  # Signal smoothing window

# Pattern Matching
pattern_lookback=10  # Periods for trend analysis
```

### Technical Indicator Settings
```python
# Bollinger Bands
bb_period=14         # SMA period
bb_std_multiplier=2.0 # Standard deviation multiplier

# RSI
rsi_period=14        # RSI calculation period

# ATR
atr_period=14        # ATR calculation period

# ZigZag
depth=12             # Minimum bars for high/low
deviation=5          # Minimum percentage move
backstep=2           # Lookback verification
```

---

## 📚 Usage Examples

### Basic Analysis
```python
# Initialize system
system = AdvancedTradingSystem(symbol='AAPL', period='6mo')

# Run complete analysis
results = system.run_analysis()

# Get current market signals
signals = system.get_current_signals(results)
print(f"Current Price: ${signals['price']:.2f}")
print(f"KNN MA: ${signals['knn_ma']:.2f}")
print(f"Recommendation: {signals['recommendation']}")
```

### Custom Symbol Analysis
```python
# Analyze different assets
stocks = ['AAPL', 'GOOGL', 'TSLA', 'BTC-USD']

for symbol in stocks:
    system = AdvancedTradingSystem(symbol=symbol, period='1y')
    results = system.run_analysis()
    
    if results:
        signals = system.get_current_signals(results)
        print(f"{symbol}: {signals['recommendation']}")
```

---

## 🚀 Advanced Features

### Real-time Analysis
- **Live Data**: Yahoo Finance real-time feeds
- **Multiple Timeframes**: 1M to 5Y analysis periods
- **Popular Symbols**: Pre-configured watchlist

### Interactive Interface
- **Dynamic Charts**: Toggle between main and detailed views
- **Responsive Design**: Works on desktop and mobile
- **Real-time Updates**: Instant analysis results

### Risk Management
- **ATR-based Stops**: Dynamic stop-loss levels
- **Volatility Awareness**: Adjust position sizes based on ATR
- **Multi-timeframe Confirmation**: Cross-verify signals

---

## 📊 Interpretation Guide

### Bullish Signals
- Price above KNN MA (trend confirmation)
- RSI between 30-70 (healthy momentum)
- KNN Prediction > 0 (algorithm bullish)
- Price above BB basis (above average)
- Recent Granville buy signals (B1, B4)

### Bearish Signals  
- Price below KNN MA (downtrend)
- RSI > 70 or declining (overbought/weakening)
- KNN Prediction < 0 (algorithm bearish)
- Price below BB basis (below average)
- Recent Granville sell signals (S5, S8)

### Risk Factors
- High ATR = increased volatility/risk
- Price near BB extremes = potential reversal
- Conflicting indicators = wait for clarity
- Low volume confirmation = weak signals

---

## 🔮 Future Enhancements

### Potential Improvements
1. **Volume Analysis**: Include volume-based indicators
2. **Sentiment Integration**: News and social media sentiment
3. **Multi-asset Correlation**: Cross-market analysis
4. **Machine Learning Enhancement**: Deep learning integration
5. **Backtesting Module**: Historical performance testing
6. **Alerts System**: Real-time signal notifications

### Scalability Considerations
- **Database Integration**: Store historical analysis
- **Caching Layer**: Reduce API calls and computation
- **Microservices**: Separate analysis and visualization
- **WebSocket Updates**: Real-time data streaming

---

## ⚠️ Risk Disclaimer

This system is for **educational and research purposes only**. Key considerations:

- **No Financial Advice**: Results should not be considered financial advice
- **Market Risk**: All trading involves risk of loss
- **Backtesting Required**: Test strategies before real money deployment
- **Diversification**: Never rely on a single indicator or system
- **Professional Consultation**: Consult financial advisors for investment decisions

---

## 🛠️ Technical Requirements

### Dependencies
```python
flask==2.3.3
yfinance==0.2.18
pandas==2.0.3
numpy==1.24.3
matplotlib==3.7.2
```

### System Requirements
- **Python**: 3.8 or higher
- **Memory**: 4GB RAM minimum
- **Storage**: 1GB for data caching
- **Network**: Internet connection for data feeds

### Installation
```bash
pip install flask yfinance pandas numpy matplotlib
python KNN_prediction_flask.py
```

Access the application at `http://localhost:5000`

---

*This documentation provides a comprehensive understanding of the KNN Stock Prediction System. The combination of machine learning algorithms with traditional technical analysis creates a robust framework for market analysis and trading signal generation.*



# =====================================================
# Flsk APP note

# Advanced Trading System Flask App

## Requirements.txt
```
Flask==2.3.3
yfinance==0.2.25
pandas==2.1.4
numpy==1.24.3
matplotlib==3.8.2
```

## Setup Instructions

### 1. Create Project Structure
```
trading_app/
├── app.py                  # Main Flask application
├── requirements.txt        # Python dependencies
├── templates/
│   └── knn_index.html         # HTML template
└── static/ (optional)
    ├── css/
    ├── js/
    └── images/
```

### 2. Installation Steps

1. **Create virtual environment:**
```bash
python -m venv trading_env
source trading_env/bin/activate  # On Windows: trading_env\Scripts\activate
```

2. **Install dependencies:**
```bash
pip install -r requirements.txt
```

3. **Create templates folder:**
```bash
mkdir templates
```

4. **Save the HTML template as `templates/index.html`**

5. **Run the application:**
```bash
python app.py
```

6. **Open browser and navigate to:**
```
http://localhost:5000
```

## Features

### 🚀 Core Functionality
- **AI KNN Moving Average**: Advanced machine learning-based moving average
- **Granville's 8 Rules**: Classic technical analysis signals
- **Bollinger Bands**: Volatility-based indicators
- **ZigZag Indicator**: Trend identification
- **RSI Analysis**: Momentum oscillator
- **ATR Targets**: Price target calculations

### 📊 Web Interface Features
- **Real-time Analysis**: Live market data from Yahoo Finance
- **Interactive Charts**: TradingView-style visualizations
- **Multiple Timeframes**: 1M to 5Y analysis periods
- **Trading Signals**: Buy/Sell signal identification
- **Responsive Design**: Works on desktop and mobile

### 🎯 Trading Signals
- **B1**: Breakthrough signals
- **B4**: Oversold bounce signals
- **S5**: Moving average breakdown
- **S8**: Overbought reversal signals
- **EB/ES**: Early buy/sell signals

## API Endpoints

### POST /api/analyze
Analyze a stock symbol and return complete trading analysis.

**Request:**
```json
{
  "symbol": "AAPL",
  "period": "6mo"
}
```

**Response:**
```json
{
  "success": true,
  "symbol": "AAPL",
  "current_signals": {
    "price": 150.25,
    "knn_ma": 148.30,
    "rsi": 65.2,
    "bb_position": "Above Basis",
    "knn_prediction": 0.75,
    "latest_signal": "B1_Breakthrough"
  },
  "recommendation": "BULLISH BIAS",
  "recommendation_color": "success",
  "signals_count": 3,
  "main_chart": "base64_encoded_image",
  "detailed_chart": "base64_encoded_image"
}
```

### GET /api/symbols
Get list of popular trading symbols.

## Customization Options

### 1. Add New Indicators
```python
def calculate_custom_indicator(self, period=14):
    """Add your custom indicator here"""
    # Implementation
    return indicator_values
```

### 2. Modify Signal Logic
```python
def identify_custom_signals(self, data):
    """Customize signal identification"""
    # Your signal logic
    return signals
```

### 3. Style Customization
- Modify CSS in the HTML template
- Add custom color schemes
- Change chart styling

## Production Deployment

### 1. Environment Variables
```python
import os

app.secret_key = os.environ.get('SECRET_KEY', 'your-secret-key')
debug_mode = os.environ.get('FLASK_DEBUG', 'False').lower() == 'true'
```

### 2. WSGI Configuration
```python
# wsgi.py
from app import app

if __name__ == "__main__":
    app.run()
```

### 3. Requirements for Production
```
gunicorn==21.2.0
python-dotenv==1.0.0
```

### 4. Run with Gunicorn
```bash
gunicorn --bind 0.0.0.0:5000 wsgi:app
```

## Troubleshooting

### Common Issues

1. **Module Import Errors**
   - Ensure virtual environment is activated
   - Install all requirements: `pip install -r requirements.txt`

2. **Yahoo Finance Connection Issues**
   - Check internet connection
   - Verify symbol exists: Try with known symbols like AAPL, GOOGL

3. **Chart Display Issues**
   - Ensure matplotlib backend is compatible
   - Check browser console for JavaScript errors

4. **Memory Issues with Large Datasets**
   - Limit analysis periods for memory-constrained environments
   - Consider data caching for frequently requested symbols

### Performance Tips

1. **Caching Results**
```python
from functools import lru_cache

@lru_cache(maxsize=100)
def cached_analysis(symbol, period):
    # Cache analysis results
    pass
```

2. **Async Processing**
```python
import asyncio
from concurrent.futures import ThreadPoolExecutor

# Use threading for CPU-intensive calculations
```

## License
This project is for educational and research purposes. Use at your own risk for actual trading decisions.

## Disclaimer
This software is for educational purposes only. Past performance does not guarantee future results. Always consult with a qualified financial advisor before making investment decisions.

# ===============================
Perfect! Now let me create the requirements.txt file and a simple setup guide:## Summary

I've successfully created a comprehensive Flask web application for your Python-based trading system! Here's what you now have:

### 🚀 **Complete Flask Application**
1. **Main Flask App** (`app.py`) - Full backend with all your trading analysis logic
2. **Beautiful Web Interface** - Modern, responsive HTML template with Bootstrap 5
3. **Setup Guide** - Complete installation and deployment instructions

### 🎯 **Key Features**

**Backend Capabilities:**
- AI KNN Moving Average calculations
- Granville's 8 Rules signal detection
- Bollinger Bands, RSI, ZigZag indicators
- ATR-based price targets
- Real-time chart generation

**Frontend Features:**
- Dark theme matching TradingView style
- Live analysis dashboard
- Interactive charts with tabs (Main Chart + Detailed Analysis)
- Real-time metrics display
- Trading recommendation engine
- Popular symbols quick-select
- Mobile-responsive design

### 📊 **How to Use**

1. **Setup:**
   ```bash
   pip install Flask yfinance pandas numpy matplotlib
   mkdir templates
   # Save HTML as templates/index.html
   python app.py
   ```

2. **Access:** Open `http://localhost:5000`

3. **Analyze:** Enter any stock symbol (AAPL, GOOGL, TSLA, etc.) and get instant analysis

### 🎨 **UI Highlights**
- **Real-time Metrics:** Current price, KNN MA, RSI, BB position
- **Trading Signals:** Buy/Sell signals with visual indicators
- **Chart Visualization:** Pine Script-style candlestick charts
- **Recommendation System:** BULLISH/BEARISH/NEUTRAL with confidence scores
- **ATR Targets:** Price targets based on Average True Range

The web app provides the same comprehensive analysis as your Python script but with a professional, user-friendly interface that traders can use in real-time!