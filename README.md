# naldodj-hb-ai-agents

![AutonomosAgents](https://github.com/user-attachments/assets/53ff7ee2-fbb5-48ca-8c0f-2d7150281fe3)

Bem-vindo ao **naldodj-hb-ai-agents**, um framework para desenvolver agentes de inteligência artificial autônomos utilizando a linguagem Harbour. Este projeto oferece uma estrutura modular para criar e gerenciar agentes de IA, com suporte a tarefas como operações no sistema de arquivos, cálculos matemáticos e consultas de tempo. Ideal para desenvolvedores que trabalham com sistemas xBase e desejam implementar automações inteligentes.

## Descrição do Projeto

O "naldodj-hb-ai-agents" é projetado para facilitar a criação de agentes de IA em Harbour. Ele inclui classes centrais como `TAgent`, `TOLlama` e `TLMStudio`, além de agentes especializados para tarefas específicas. O framework é acompanhado por uma suite de testes para validação e exemplos práticos.

## Componentes Principais

Os arquivos do projeto estão organizados em três categorias principais:

### Core Files
- **[tagent.prg](https://github.com/naldodj/naldodj-hb-ai-agents/blob/main/src/core/tagent.prg)**: Implementação da classe `TAgent`, base para a criação de agentes.
- **[tollama.prg](https://github.com/naldodj/naldodj-hb-ai-agents/blob/main/src/core/tollama.prg)**: Implementação da classe `TOLlama`, essencial para a gestão de agentes.
- **[tlmstudio.prg](https://github.com/naldodj/naldodj-hb-ai-agents/blob/main/src/core/tlmstudio.prg)**: Implementação da classe `TLMStudio`, essencial para a integração com o LMStudio.

### Agent Files
- **[agent_filesystem.prg](https://github.com/naldodj/naldodj-hb-ai-agents/blob/main/src/agents/agent_filesystem.prg)**: Agente para operações no sistema de arquivos (ex.: criar pastas, modificar arquivos).
- **[agent_math.prg](https://github.com/naldodj/naldodj-hb-ai-agents/blob/main/src/agents/agent_math.prg)**: Agente para cálculos matemáticos.
- **[agent_datetime.prg](https://github.com/naldodj/naldodj-hb-ai-agents/blob/main/src/agents/agent_datetime.prg)**: Agente para consultas relacionadas a data e hora (ex.: "Que horas são?", "Qual a data de hoje?").

### Test Files
- **[hb_agents_ollama.prg](https://github.com/naldodj/naldodj-hb-ai-agents/blob/main/src/tst/hb_agents_ollama.prg)**: Suite de testes para demonstrar e validar o funcionamento do framework com `TOLlama`.
- **[hb_agents_lmstudio.prg](https://github.com/naldodj/naldodj-hb-ai-agents/blob/main/src/tst/hb_agents_lmstudio.prg)**: Suite de testes para demonstrar e validar o funcionamento do framework com `TLMStudio`.

## Como Usar

1. **Pré-requisitos**:
   - Certifique-se de ter um compilador Harbour instalado em seu ambiente.
   - Instale o [Ollama](https://ollama.ai/) localmente, pois ele é necessário para executar os testes e utilizar a classe `TOLlama`.
   - Instale o [LMStudio](https://lmstudio.ai/) como uma alternativa ao Ollama.

2. **Instalação**: Clone o repositório para sua máquina:
   ```bash
   git clone https://github.com/naldodj/naldodj-hb-ai-agents.git
   cd ./naldodj-hb-ai-agents/src/tst
   hbmk2.exe hb_agents_ollama.hbp
   ./hb_agents_ollama
   hbmk2.exe hb_agents_lmstudio.hbp
   ./hb_agents_lmstudio
   ```

3. **Configuração do LMStudio**:
   - Baixe e instale o [LMStudio](https://lmstudio.ai/).
   - Certifique-se de que o LMStudio está rodando e configurado corretamente para responder às chamadas do framework.
   
4. **Compilação**: Compile os arquivos `.prg` usando o compilador Harbour.

5. **Exemplos de Uso**:
   - Perguntar "Que horas são?" ou "Qual a data de hoje?" (usando `agent_datetime.prg`).
   - Criar uma pasta chamada "test" (usando `agent_filesystem.prg`).
   - Modificar um arquivo com o conteúdo "Hello World" (usando `agent_filesystem.prg`).

## Suporte e Referências

Para mais informações, exemplos práticos e suporte técnico, consulte a discussão nos fóruns da FiveTech Software:
- **Ref.: FiveTech Software Tech Support Forums**  
  [Class TOllama with Agents](https://forums.fivetechsupport.com/viewtopic.php?t=45590&fbclid=IwY2xjawJabspleHRuA2FlbQIxMQABHfr9ZnmiZDE_sf1ZHzer4gx9RbwfpOb1xNSCqMlZuCmoEf4erO3UrABH9g_aem_IritY9uodOibezq_rQ8i1g)

## Contribuições

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou enviar pull requests com melhorias, novos agentes ou correções.

## Licença

Este projeto está disponível sob os termos da licença [Apache License Version 2.0]. Veja o arquivo LICENSE para mais detalhes.

---

Desenvolvido por [naldodj](https://github.com/naldodj).
