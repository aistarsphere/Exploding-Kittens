enum PromptType {
  seeFuture,
  alterFuture,
  favorGive,
  catPairTarget,
  catTrioTarget,
  catTrioName,
  defuseReinsert;

  static PromptType fromString(String s) {
    const map = {
      'see-future':      PromptType.seeFuture,
      'alter-future':    PromptType.alterFuture,
      'favor-give':      PromptType.favorGive,
      'cat-pair-target': PromptType.catPairTarget,
      'cat-trio-target': PromptType.catTrioTarget,
      'cat-trio-name':   PromptType.catTrioName,
      'defuse-reinsert': PromptType.defuseReinsert,
    };
    return map[s] ?? PromptType.seeFuture;
  }
}
