// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_ashby/otel_ashby.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_ashby-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('application.changeStage records candidate + stage + source', () async {
    await tracedAshby<String>(
      operation: 'application.changeStage',
      invoke: () async => const AshbyCallResult(
        value: 'ok',
        result: AshbyResult(
          candidateId: 'cand_1',
          applicationId: 'app_1',
          applicationStatus: 'Active',
          applicationStage: 'Onsite',
          jobId: 'job_1',
          jobStatus: 'Open',
          locationId: 'loc_1',
          sourceName: 'Referral',
          statusCode: 200,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('ashby application.changeStage')!);
    expect(a['ashby.application.status'], 'Active');
    expect(a['ashby.application.stage'], 'Onsite');
    expect(a['ashby.source.name'], 'Referral');
  });

  test('archived application captures reason without span error', () async {
    await tracedAshby<String>(
      operation: 'application.archive',
      invoke: () async => const AshbyCallResult(
        value: 'ok',
        result: AshbyResult(
          applicationId: 'app_2',
          applicationStatus: 'Archived',
          archiveReason: 'Underqualified',
        ),
      ),
    );
    final s = spans.findSpanByName('ashby application.archive')!;
    expect(s.status, isNot(SpanStatusCode.Error));
    expect(attrsOf(s)['ashby.archive.reason'], 'Underqualified');
  });

  test('referral with bonus records cents amount', () async {
    await tracedAshby<String>(
      operation: 'referral.create',
      invoke: () async => const AshbyCallResult(
        value: 'ok',
        result: AshbyResult(
          candidateId: 'cand_3',
          referralBonusUsd: 250000,
          statusCode: 201,
        ),
      ),
    );
    expect(
      attrsOf(spans.findSpanByName('ashby referral.create')!)[
          'ashby.referral.bonus_cents'],
      250000,
    );
  });

  test('feedbackForm.submit records form + rating', () async {
    await tracedAshby<String>(
      operation: 'feedbackForm.submit',
      invoke: () async => const AshbyCallResult(
        value: 'ok',
        result: AshbyResult(
          feedbackFormId: 'ff_1',
          feedbackRating: '4',
          statusCode: 200,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('ashby feedbackForm.submit')!);
    expect(a['ashby.feedback_form.id'], 'ff_1');
    expect(a['ashby.feedback.rating'], '4');
  });

  test('suppression skips spans', () async {
    await runWithoutAshbyInstrumentationAsync(() async {
      await tracedAshby<String>(
        operation: 'job.list',
        invoke: () async => const AshbyCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('ashby '), isEmpty);
  });
}
