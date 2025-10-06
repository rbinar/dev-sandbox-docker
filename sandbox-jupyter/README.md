## Docker-Jupyter Konteynerini Başlatma

Terminalde `docker-jupyter-cli.md` içindeki komutları çalıştırarak docker-jupyter konteynerini başlatabilirsiniz.

### Docker Compose ile Başlatma

Yada `docker-compose.yml` dosyasını kullanarak başlatabilirsiniz.

```bash
docker-compose up -d
```

Her iki durumda da, konteyner başlatıldıktan sonra [`http://localhost:8888`](http://localhost:8888) adresinden Jupyter Notebook'a erişebilirsiniz.

**Not:** Giriş yaparken `docker-compose.yml` dosyasında belirttiğiniz JUPYTER_TOKEN değerini kullanmanız gerekiyor.

### 🐍 **Jupyter DataScience Notebook Features**

Bu sandbox **jupyter/datascience-notebook** image'ını kullanır ve şunları içerir:
- **Python 3** with pandas, numpy, matplotlib, scikit-learn
- **R** with popular data science packages
- **Julia** programming language
- **Jupyter Lab** interface (modern UI)
- **Pre-installed packages**: TensorFlow, PyTorch, scipy, seaborn

### Güvenlik Kullanım Senaryoları

- **Bilinmeyen notebook'lar**: GitHub'dan indirilen .ipynb dosyalarını güvenle çalıştırma
- **Data science güvenliği**: Şüpheli veri setlerini izole ortamda analiz etme
- **Python kod testi**: Güvenilmeyen Python scriptlerini ana sistem etkilemeden test etme
- **Machine learning deneyleri**: Kaynak tüketen ML modellerini kontrollü ortamda çalıştırma

## Kaynaklar

- [Jupyter Docker Stacks - datascience-notebook](https://jupyter-docker-stacks.readthedocs.io/en/latest/using/selecting.html#jupyter-datascience-notebook)