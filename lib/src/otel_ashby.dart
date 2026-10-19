// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_ashby_suppression.dart';

const _tracerName = 'dartastic_otel_libs_ashby';

APITracer _tracer() => OTelAPI.tracerProvider().getTracer(_tracerName);

class AshbyResult {
  const AshbyResult({
    this.entityKind,
    this.entityId,
    this.candidateId,
    this.applicationId,
    this.applicationStatus,
    this.applicationStage,
    this.archiveReason,
    this.jobId,
    this.jobStatus,
    this.locationId,
    this.sourceName,
    this.interviewId,
    this.interviewStatus,
    this.feedbackFormId,
    this.feedbackRating,
    this.offerStatus,
    this.referralBonusUsd,
    this.statusCode,
  });

  /// `candidate` / `application` / `job` / `interview` / `interview_event` /
  /// `feedback_form` / `feedback_form_definition` / `offer` /
  /// `referral` / `source` / `user` / `location`.
  final String? entityKind;

  final String? entityId;

  final String? candidateId;
  final String? applicationId;

  /// `Active` / `Hired` / `Archived` / `Lead`.
  final String? applicationStatus;

  /// Current stage in the interview plan (job-defined: `Application
  /// Review` / `Recruiter Screen` / `Onsite` / `Offer` / ...).
  final String? applicationStage;

  /// Filled when applicationStatus is `Archived`.
  final String? archiveReason;

  final String? jobId;

  /// `Open` / `Draft` / `Closed`.
  final String? jobStatus;

  final String? locationId;

  /// Source the candidate came from (Ashby tracks fine-grained
  /// channels).
  final String? sourceName;

  final String? interviewId;

  /// `Confirmed` / `WaitingOnCandidate` / `WaitingOnHiringTeam` /
  /// `Cancelled` / `Completed`.
  final String? interviewStatus;

  final String? feedbackFormId;

  /// `1` through `4` (Ashby uses a 1-4 rating scale) or qualitative
  /// label.
  final String? feedbackRating;

  /// `Draft` / `PendingApproval` / `Approved` / `Sent` / `Accepted`
  /// / `Rejected` / `Withdrawn` / `Cancelled`.
  final String? offerStatus;

  /// Referral bonus amount in USD cents (when a referral resulted
  /// in a hire).
  final int? referralBonusUsd;

  final int? statusCode;
}

class AshbyCallResult<T> {
  const AshbyCallResult({required this.value, this.result});
  final T value;
  final AshbyResult? result;
}

/// Wraps an Ashby API call in a CLIENT span. [operation] is one of
/// `candidate.create`, `candidate.list`, `application.create`,
/// `application.changeStage`, `application.archive`,
/// `application.unarchive`, `job.list`, `job.create`,
/// `interview.list`, `interviewSchedule.create`,
/// `feedbackForm.submit`, `offer.create`, `referral.create`,
/// `apiKey.info`.
Future<T> tracedAshby<T>({
  required String operation,
  required Future<AshbyCallResult<T>> Function() invoke,
}) async {
  if (ashbyInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'ashby',
    'rpc.method': operation,
    'ashby.operation': operation,
  };

  final span = _tracer().startSpan(
    'ashby $operation',
    kind: SpanKind.client,
    attributes: OTelAPI.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final extras = <Attribute<Object>>[];
      if (r.result!.entityKind != null) {
        extras.add(OTelAPI.attributeString(
          'ashby.entity.kind',
          r.result!.entityKind!,
        ));
      }
      if (r.result!.entityId != null) {
        extras.add(OTelAPI.attributeString(
          'ashby.entity.id',
          r.result!.entityId!,
        ));
      }
      if (r.result!.candidateId != null) {
        extras.add(OTelAPI.attributeString(
          'ashby.candidate.id',
          r.result!.candidateId!,
        ));
      }
      if (r.result!.applicationId != null) {
        extras.add(OTelAPI.attributeString(
          'ashby.application.id',
          r.result!.applicationId!,
        ));
      }
      if (r.result!.applicationStatus != null) {
        extras.add(OTelAPI.attributeString(
          'ashby.application.status',
          r.result!.applicationStatus!,
        ));
      }
      if (r.result!.applicationStage != null) {
        extras.add(OTelAPI.attributeString(
          'ashby.application.stage',
          r.result!.applicationStage!,
        ));
      }
      if (r.result!.archiveReason != null) {
        extras.add(OTelAPI.attributeString(
          'ashby.archive.reason',
          r.result!.archiveReason!,
        ));
      }
      if (r.result!.jobId != null) {
        extras.add(OTelAPI.attributeString(
          'ashby.job.id',
          r.result!.jobId!,
        ));
      }
      if (r.result!.jobStatus != null) {
        extras.add(OTelAPI.attributeString(
          'ashby.job.status',
          r.result!.jobStatus!,
        ));
      }
      if (r.result!.locationId != null) {
        extras.add(OTelAPI.attributeString(
          'ashby.location.id',
          r.result!.locationId!,
        ));
      }
      if (r.result!.sourceName != null) {
        extras.add(OTelAPI.attributeString(
          'ashby.source.name',
          r.result!.sourceName!,
        ));
      }
      if (r.result!.interviewId != null) {
        extras.add(OTelAPI.attributeString(
          'ashby.interview.id',
          r.result!.interviewId!,
        ));
      }
      if (r.result!.interviewStatus != null) {
        extras.add(OTelAPI.attributeString(
          'ashby.interview.status',
          r.result!.interviewStatus!,
        ));
      }
      if (r.result!.feedbackFormId != null) {
        extras.add(OTelAPI.attributeString(
          'ashby.feedback_form.id',
          r.result!.feedbackFormId!,
        ));
      }
      if (r.result!.feedbackRating != null) {
        extras.add(OTelAPI.attributeString(
          'ashby.feedback.rating',
          r.result!.feedbackRating!,
        ));
      }
      if (r.result!.offerStatus != null) {
        extras.add(OTelAPI.attributeString(
          'ashby.offer.status',
          r.result!.offerStatus!,
        ));
      }
      if (r.result!.referralBonusUsd != null) {
        extras.add(OTelAPI.attributeInt(
          'ashby.referral.bonus_cents',
          r.result!.referralBonusUsd!,
        ));
      }
      if (r.result!.statusCode != null) {
        extras.add(OTelAPI.attributeInt(
          'http.response.status_code',
          r.result!.statusCode!,
        ));
        if (r.result!.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Ashby HTTP ${r.result!.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTelAPI.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTelAPI.attributes([
      OTelAPI.attributeString(
        ErrorAttributes.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
