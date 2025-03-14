# Concurrency и Parallelism

Concurrency — это способность программы обрабатывать несколько задач одновременно, но не обязательно в один и тот же момент времени. Это достигается за счёт чередования выполнения задач

Parallelism — это выполнение нескольких задач одновременно на разных процессорных ядрах

Ruby MRI (Matz’s Ruby Interpreter), который является основной реализацией Ruby, использует GIL (Global Interpreter Lock). Это означает, что в один момент времени может выполняться только один поток Ruby-кода, даже если у программы есть несколько потоков (threads). 

При этом Ruby может обрабатывать задачи конкурентно потому что во время ожидания блокировки GIL снимается и управление можно передать другому потоку

Чтобы обойти GIL и достичь параллелизма, можно:
  - Использовать многопроцессную модель (например, fork или Puma в режиме cluster)
  - Использовать альтернативные Ruby-интерпретаторы, например JRuby, который поддерживает настоящий параллелизм


# Concurrency in Rails

Используя Puma можно настраивать режим работы:
  - Многопоточный режим (Threads mode)
  - Многопроцессный режим (Cluster mode, Workers mode)

```ruby
# config/puma.rb

workers 2 # Два процесса (worker)
threads 5, 5 # По 5 потоков в каждом процессе
```

## Threads mode

1. Запускается один процесс, внутри которого есть несколько потоков (например, 5-16)
2. Каждый поток обрабатывает один HTTP-запрос
3. Потоки разделяют память, что экономит ресурсы, но не позволяет обойти GIL (CPU-bound задачи не ускоряются)
4. Подходит для I/O-bound приложений, где важна конкурентность

## Cluster mode, Workers mode

1. Запускается несколько процессов, каждый со своими потоками.
2. Процессы изолированы и могут выполняться параллельно (по-настоящему, на разных ядрах).
3. Работает как fork, создавая копии родительского процесса.
4. Подходит для CPU-bound приложений или heavy load сценариев.

Так как часто rails apps запускают в K8S, то cluster mode не нужен и происходит скейлинг приложения с помощью pods,
где у каждого pod будет свой процесс со своими потоками

Важно отметить, что зачастую тяжёлые задачи обрабатываются с помощью Sidekiq (у которого есть свой процесс и потоки)
И его тоже можно настраивать (увеличивать кол-во потоков или скейлить с помощью pods)



