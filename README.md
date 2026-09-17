# Supply Chain Analytics Dashboard

## Overview

Project ini merupakan **dashboard analitik Supply Chain** yang dibuat untuk membantu memantau kondisi inventory dan beberapa indikator utama dalam proses supply chain melalui visualisasi data yang interaktif.

Dashboard dirancang untuk membantu mengidentifikasi permasalahan inventory dan memberikan gambaran mengenai kondisi stok, produk yang berpotensi mengalami *out of stock*, purchase order supplier, serta inventory yang sudah tersimpan dalam waktu lama.

## Business Questions

Dashboard ini dibuat untuk menjawab beberapa pertanyaan bisnis, antara lain:

* Berapa total inventory dan nilai inventory yang tersedia?
* Produk apa saja yang memiliki stok rendah atau berpotensi mengalami *out of stock*?
* Purchase order supplier mana yang belum terpenuhi?
* Produk mana yang memiliki inventory dengan usia penyimpanan yang tinggi?
* Bagaimana kondisi inventory berdasarkan warehouse dan produk?

## Dashboard Pages

Dashboard terdiri dari empat halaman utama:

### 1. Inventory Overview

Menampilkan gambaran umum kondisi inventory, seperti total nilai inventory, jumlah stok, jumlah SKU, serta distribusi tingkat stok.

### 2. Out of Stock Analysis

Menganalisis produk dengan stok rendah atau tidak tersedia untuk membantu mengidentifikasi potensi masalah *stockout*.

### 3. Supplier Purchase Orders

Menampilkan dan menganalisis purchase order dari supplier serta mengidentifikasi order yang belum terpenuhi.

### 4. Aging Inventory

Menganalisis inventory berdasarkan lama waktu penyimpanan untuk membantu mengidentifikasi inventory yang sudah terlalu lama berada di warehouse.

## Tech Stack

* **PostgreSQL** — Penyimpanan dan pengolahan data
* **DBeaver** — Manajemen database dan pengembangan SQL
* **SQL** — Data preparation dan analisis data
* **Power BI** — Visualisasi data dan pengembangan dashboard

## Project Structure

```text
SupplyChain-PowerBI/
│
├── PowerBI/
│   └── File dashboard Power BI
│
├── SQL/
│   └── Script SQL untuk pengolahan dan analisis data
│
├── Dataset/
│   └── Informasi dan dokumentasi dataset
│
├── Dashboard/
│   └── Preview dashboard
│
└── README.md
```

## Key Skills Demonstrated

* Data analysis using SQL
* Data cleaning and transformation
* Supply chain analytics
* Inventory analysis
* KPI development
* Data visualization
* Interactive dashboard development
* Business-oriented data storytelling

## Dashboard Preview

Preview dashboard tersedia di dalam folder `Dashboard/`.

## Tujuan Project

Project ini dibuat sebagai **portfolio project** untuk menunjukkan penerapan SQL, data analysis, dan Business Intelligence dalam kasus Supply Chain.
