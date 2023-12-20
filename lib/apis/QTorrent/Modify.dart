part of 'QTorrent.dart';

extension Modify on QTorrent {
  Future<Status> rename(String hash, String name) async {
    Response response;

    Map<String, String> headers = {
      'hash': hash,
      'name': name,
    };

    response = await _makeRequest(HttpMethod.post, 'torrents/rename', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> setCategory(String hash, String category) async {
    Response response;

    Map<String, String> headers = {
      'hash': hash,
      'category': category,
    };

    response = await _makeRequest(HttpMethod.post, 'torrents/setCategory', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> pause(String hash) async {
    Response response;

    Map<String, String> headers = {
      'hashes': hash,
    };

    response = await _makeRequest(HttpMethod.post, 'torrents/pause', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> pauseMultiple(List<String> hashes) async {
    Response response;

    Map<String, String> headers = {
      'hashes': hashes.join('|'),
    };

    response = await _makeRequest(HttpMethod.post, 'torrents/pause', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> resume(String hash) async {
    Response response;

    Map<String, String> headers = {
      'hashes': hash,
    };

    response = await _makeRequest(HttpMethod.post, 'torrents/resume', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> resumeMultiple(List<String> hashes) async {
    Response response;

    Map<String, String> headers = {
      'hashes': hashes.join('|'),
    };

    response = await _makeRequest(HttpMethod.post, 'torrents/resume', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> toggleForceStart(String hash) async {
    Response response;

    Map<String, String> headers = {
      'hashes': hash,
    };

    response = await _makeRequest(HttpMethod.post, 'torrents/toggleForceStart', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> toggleForceStartMultiple(List<String> hashes) async {
    Response response;

    Map<String, String> headers = {
      'hashes': hashes.join('|'),
    };

    response = await _makeRequest(HttpMethod.post, 'torrents/toggleForceStart', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> recheck(String hash) async {
    Response response;

    Map<String, String> headers = {
      'hashes': hash,
    };

    response = await _makeRequest(HttpMethod.post, 'torrents/recheck', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> recheckMultiple(List<String> hashes) async {
    Response response;

    Map<String, String> headers = {
      'hashes': hashes.join('|'),
    };

    response = await _makeRequest(HttpMethod.post, 'torrents/recheck', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> verify(String hash) async {
    Response response;

    Map<String, String> headers = {
      'hashes': hash,
    };

    response = await _makeRequest(HttpMethod.post, 'torrents/verify', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> verifyMultiple(List<String> hashes) async {
    Response response;

    Map<String, String> headers = {
      'hashes': hashes.join('|'),
    };

    response = await _makeRequest(HttpMethod.post, 'torrents/verify', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> delete(String hash, bool deleteData) async {
    Response response;

    Map<String, String> headers = {
      'hashes': hash,
      'deleteFiles': deleteData.toString(),
    };

    response = await _makeRequest(HttpMethod.post, 'torrents/delete', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> deleteMultiple(List<String> hashes, bool deleteData) async {
    Response response;

    Map<String, String> headers = {
      'hashes': hashes.join('|'),
      'deleteFiles': deleteData.toString(),
    };

    response = await _makeRequest(HttpMethod.post, 'torrents/delete', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> increasePriority(String hash) async {
    Response response;

    Map<String, String> headers = {
      'hashes': hash,
    };

    response = await _makeRequest(HttpMethod.post, 'torrents/increasePrio', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> increasePriorityMultiple(List<String> hashes) async {
    Response response;

    Map<String, String> headers = {
      'hashes': hashes.join('|'),
    };

    response = await _makeRequest(HttpMethod.post, 'torrents/increasePrio', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> decreasePriority(String hash) async {
    Response response;

    Map<String, String> headers = {
      'hashes': hash,
    };

    response = await _makeRequest(HttpMethod.post, 'torrents/decreasePrio', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> decreasePriorityMultiple(List<String> hashes) async {
    Response response;

    Map<String, String> headers = {
      'hashes': hashes.join('|'),
    };

    response = await _makeRequest(HttpMethod.post, 'torrents/decreasePrio', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> topPriority(String hash) async {
    Response response;

    Map<String, String> headers = {
      'hashes': hash,
    };

    response = await _makeRequest(HttpMethod.post, 'torrents/topPrio', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> topPriorityMultiple(List<String> hashes) async {
    Response response;

    Map<String, String> headers = {
      'hashes': hashes.join('|'),
    };

    response = await _makeRequest(HttpMethod.post, 'torrents/topPrio', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> bottomPriority(String hash) async {
    Response response;

    Map<String, String> headers = {
      'hashes': hash,
    };

    response = await _makeRequest(HttpMethod.post, 'torrents/bottomPrio', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> bottomPriorityMultiple(List<String> hashes) async {
    Response response;

    Map<String, String> headers = {
      'hashes': hashes.join('|'),
    };

    response = await _makeRequest(HttpMethod.post, 'torrents/bottomPrio', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> setFilePriority(String hash, int id, int priority) async {
    Response response;

    Map<String, String> headers = {
      'hash': hash,
      'id': id.toString(),
      'priority': priority.toString(),
    };

    response = await _makeRequest(HttpMethod.post, 'torrents/filePrio', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> setFilePriorityMultiple(
      String hash, List<int> ids, int priority) async {
    Response response;

    Map<String, String> headers = {
      'hash': hash,
      'id': ids.join('|'),
      'priority': priority.toString(),
    };

    response = await _makeRequest(HttpMethod.post, 'torrents/filePrio', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> toggleSequentialDownload(String hash) async {
    Response response;

    Map<String, String> headers = {
      'hashes': hash,
    };

    response =
        await _makeRequest(HttpMethod.post, 'torrents/toggleSequentialDownload', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> toggleSequentialDownloadMultiple(List<String> hashes) async {
    Response response;

    Map<String, String> headers = {
      'hashes': hashes.join('|'),
    };

    response =
        await _makeRequest(HttpMethod.post, 'torrents/toggleSequentialDownload', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> toggleFirstLastPiecePriority(String hash) async {
    Response response;

    Map<String, String> headers = {
      'hashes': hash,
    };

    response = await _makeRequest(
        HttpMethod.post, 'torrents/toggleFirstLastPiecePrio', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> toggleFirstLastPiecePriorityMultiple(List<String> hashes) async {
    Response response;

    Map<String, String> headers = {
      'hashes': hashes.join('|'),
    };

    response = await _makeRequest(
        HttpMethod.post, 'torrents/toggleFirstLastPiecePrio', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> setShareLimits(String hash, int ratioLimit, int seedingTimeLimit) async {
    Response response;

    Map<String, String> headers = {
      'hash': hash,
      'ratioLimit': ratioLimit.toString(),
      'seedingTimeLimit': seedingTimeLimit.toString(),
    };

    response = await _makeRequest(HttpMethod.post, 'torrents/setShareLimits', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> setShareLimitsMultiple(
      List<String> hashes, int ratioLimit, int seedingTimeLimit) async {
    Response response;

    Map<String, String> headers = {
      'hashes': hashes.join('|'),
      'ratioLimit': ratioLimit.toString(),
      'seedingTimeLimit': seedingTimeLimit.toString(),
    };

    response = await _makeRequest(HttpMethod.post, 'torrents/setShareLimits', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> setAutoManagement(String hash, bool enable) async {
    Response response;

    Map<String, String> headers = {
      'hash': hash,
      'enable': enable.toString(),
    };

    response = await _makeRequest(HttpMethod.post, 'torrents/setAutoManagement', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> setAutoManagementMultiple(List<String> hashes, bool enable) async {
    Response response;

    Map<String, String> headers = {
      'hashes': hashes.join('|'),
      'enable': enable.toString(),
    };

    response = await _makeRequest(HttpMethod.post, 'torrents/setAutoManagement', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> toggleSuperSeeding(String hash) async {
    Response response;

    Map<String, String> headers = {
      'hash': hash,
    };

    response = await _makeRequest(HttpMethod.post, 'torrents/toggleSuperSeeding', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> toggleSuperSeedingMultiple(List<String> hashes) async {
    Response response;

    Map<String, String> headers = {
      'hashes': hashes.join('|'),
    };

    response = await _makeRequest(HttpMethod.post, 'torrents/toggleSuperSeeding', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> addTags(String hash, String tags) async {
    Response response;

    Map<String, String> headers = {
      'hash': hash,
      'tags': tags,
    };

    response = await _makeRequest(HttpMethod.post, 'torrents/addTags', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> addTagsMultiple(List<String> hashes, String tags) async {
    Response response;

    Map<String, String> headers = {
      'hashes': hashes.join('|'),
      'tags': tags,
    };

    response = await _makeRequest(HttpMethod.post, 'torrents/addTags', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> removeTags(String hash, String tags) async {
    Response response;

    Map<String, String> headers = {
      'hash': hash,
      'tags': tags,
    };

    response = await _makeRequest(HttpMethod.post, 'torrents/removeTags', arguments: headers);

    return _reponseParser(response);
  }

  Future<Status> removeTagsMultiple(List<String> hashes, String tags) async {
    Response response;

    Map<String, String> headers = {
      'hashes': hashes.join('|'),
      'tags': tags,
    };

    response = await _makeRequest(HttpMethod.post, 'torrents/removeTags', arguments: headers);

    return _reponseParser(response);
  }
}