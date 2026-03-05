class MappingService {
  // Common IPC to BNS Mapping Data
  static const Map<String, Map<String, String>> _sections = {
    '302': {
      'old': 'IPC 302 (Murder)',
      'new': 'BNS 101',
      'desc': 'Punishment for murder.',
    },
    '420': {
      'old': 'IPC 420 (Cheating)',
      'new': 'BNS 318',
      'desc': 'Cheating and dishonestly inducing delivery of property.',
    },
    '376': {
      'old': 'IPC 376 (Rape)',
      'new': 'BNS 64',
      'desc': 'Punishment for sexual assault.',
    },
    '392': {
      'old': 'IPC 392 (Robbery)',
      'new': 'BNS 309',
      'desc': 'Punishment for robbery.',
    },
    '124A': {
      'old': 'IPC 124A (Sedition)',
      'new': 'BNS 152',
      'desc': 'Acts endangering sovereignty, unity, and integrity of India.',
    },
  };

  static Map<String, String>? getNewSection(String ipcSection) {
    return _sections[ipcSection];
  }

  static List<Map<String, String>> getAllSections() {
    return _sections.values.toList();
  }
}
