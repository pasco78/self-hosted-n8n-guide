# Self-hosted AI Starter Kit 사용 매뉴얼

## 📌 프로젝트 개요

이 프로젝트는 n8n 워크플로우 자동화 플랫폼과 AI 도구들(Ollama, Qdrant)을 Docker Compose를 통해 로컬 환경에서 쉽게 구축할 수 있도록 돕는 스타터 키트입니다.

## 🚀 빠른 시작 가이드

### 1. 초기 설정

```bash
# 1. 저장소 클론
git clone https://github.com/n8n-io/self-hosted-ai-starter-kit.git
cd self-hosted-ai-starter-kit

# 2. 환경 설정 파일 복사
cp .env.example .env

# 3. .env 파일 수정 (보안을 위해 기본값 변경 필수)
# POSTGRES_PASSWORD, N8N_ENCRYPTION_KEY, N8N_USER_MANAGEMENT_JWT_SECRET 수정
```

### 2. Windows 사용자를 위한 자동 실행 (권장)

PowerShell 스크립트 `start-n8n.ps1`을 사용하면 ngrok 터널링과 n8n을 자동으로 설정하고 실행할 수 있습니다.

```powershell
# PowerShell에서 실행
.\start-n8n.ps1
```

스크립트가 자동으로 수행하는 작업:
- ngrok 실행 (이미 실행 중이면 건너뜀)
- ngrok 공개 URL 자동 조회
- .env 파일에 WEBHOOK_URL 및 N8N_EDITOR_BASE_URL 자동 업데이트
- Docker 컨테이너 재시작

### 3. 수동 실행 (Docker Compose)

#### CPU 버전
```bash
docker compose --profile cpu up -d
```

#### GPU 버전 (NVIDIA)
```bash
docker compose --profile gpu-nvidia up -d
```

#### GPU 버전 (AMD)
```bash
docker compose --profile gpu-amd up -d
```

## 📁 프로젝트 구조

```
self-hosted-ai-starter-kit/
│
├── .env                    # 환경 변수 설정 파일 (복사 후 수정 필요)
├── .env.example           # 환경 변수 예제 파일
├── docker-compose.yml     # Docker Compose 설정
├── start-n8n.ps1          # Windows PowerShell 자동 실행 스크립트
│
├── n8n/                   # n8n 관련 파일
│   └── demo-data/        # 샘플 워크플로우 및 인증 정보
│
├── shared/               # 컨테이너 간 공유 데이터 폴더
│
├── ngrok/                # ngrok 설정 및 실행 파일 (선택사항)
│
└── assets/               # 프로젝트 리소스 (이미지, GIF 등)
```

## 🐳 구성 요소

### 핵심 서비스

1. **n8n** (포트: 5678)
   - 워크플로우 자동화 플랫폼
   - 400개 이상의 통합 지원
   - 웹 UI: http://localhost:5678

2. **PostgreSQL**
   - n8n 데이터 저장소
   - 사용자, 워크플로우, 실행 기록 저장

3. **Ollama** (포트: 11434)
   - 로컬 LLM 실행 플랫폼
   - 기본으로 llama3.2 모델 자동 설치
   - API: http://localhost:11434

4. **Qdrant** (포트: 6333)
   - 벡터 데이터베이스
   - 임베딩 저장 및 검색
   - UI: http://localhost:6333/dashboard

## ⚙️ 환경 변수 설정

`.env` 파일의 주요 설정:

```bash
# PostgreSQL 설정
POSTGRES_USER=root              # DB 사용자명
POSTGRES_PASSWORD=password      # DB 비밀번호 (변경 필수!)
POSTGRES_DB=n8n                # DB 이름

# n8n 보안 설정
N8N_ENCRYPTION_KEY=super-secret-key        # 암호화 키 (변경 필수!)
N8N_USER_MANAGEMENT_JWT_SECRET=even-more-secret  # JWT 시크릿 (변경 필수!)

# Webhook 설정 (ngrok 사용시 자동 설정됨)
WEBHOOK_URL=https://xxxx.ngrok-free.app    # ngrok URL
N8N_EDITOR_BASE_URL=https://xxxx.ngrok-free.app  # 외부 접속 URL

# Mac 사용자 (로컬 Ollama 사용시)
# OLLAMA_HOST=host.docker.internal:11434
```

## 🔌 ngrok 터널링 설정

외부에서 n8n webhook에 접근하려면 ngrok이 필요합니다.

### 자동 설정 (Windows)
`start-n8n.ps1` 스크립트가 자동으로 처리합니다.

### 수동 설정
1. ngrok 실행:
   ```bash
   ngrok http 5678
   ```

2. 생성된 URL을 `.env` 파일에 추가:
   ```bash
   WEBHOOK_URL=https://xxxx.ngrok-free.app
   N8N_EDITOR_BASE_URL=https://xxxx.ngrok-free.app
   ```

3. 컨테이너 재시작:
   ```bash
   docker compose down
   docker compose --profile cpu up -d
   ```

## 📚 사용 예제

### n8n 워크플로우 예제

1. **AI 챗봇 구축**
   - Ollama를 사용한 로컬 LLM 챗봇
   - Slack/Discord 통합

2. **문서 분석 시스템**
   - PDF 파일 업로드
   - Qdrant에 임베딩 저장
   - 의미 기반 검색

3. **자동화된 데이터 처리**
   - 웹훅으로 데이터 수신
   - AI로 분석 및 분류
   - 결과를 데이터베이스에 저장

## 🛠️ 문제 해결

### Docker 관련 문제
```bash
# 모든 컨테이너 중지 및 제거
docker compose down

# 볼륨 포함 완전 제거
docker compose down -v

# 로그 확인
docker compose logs n8n
docker compose logs ollama
```

### ngrok 연결 문제
```bash
# ngrok 상태 확인 (브라우저)
http://localhost:4040

# ngrok 프로세스 확인 (Windows PowerShell)
Get-Process | Where-Object { $_.ProcessName -eq "ngrok" }
```

### n8n 접속 문제
- 브라우저 캐시 삭제
- 다른 브라우저 시도
- 방화벽 설정 확인 (포트 5678)

## 📝 추가 리소스

- [n8n 공식 문서](https://docs.n8n.io/)
- [Ollama 모델 목록](https://ollama.com/library)
- [Qdrant 문서](https://qdrant.tech/documentation/)
- [프로젝트 GitHub](https://github.com/n8n-io/self-hosted-ai-starter-kit)

## 💡 팁

1. **보안**: 프로덕션 환경에서는 반드시 강력한 비밀번호와 암호화 키를 사용하세요.

2. **성능**: GPU가 있다면 GPU 프로필을 사용하여 AI 모델 성능을 향상시킬 수 있습니다.

3. **백업**: 중요한 워크플로우는 정기적으로 백업하세요:
   ```bash
   docker exec n8n n8n export:workflow --all --output=/demo-data/backup.json
   ```

4. **모델 추가**: Ollama에 다른 모델 추가하기:
   ```bash
   docker exec ollama ollama pull mistral
   docker exec ollama ollama pull codellama
   ```

## 🤝 기여하기

프로젝트 개선에 참여하려면 [CONTRIBUTING.md](CONTRIBUTING.md) 파일을 참조하세요.

## 📄 라이선스

이 프로젝트는 Apache-2.0 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.