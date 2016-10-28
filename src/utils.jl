export AArray, onehot, onecold, chunks

const AArray = AbstractArray

onehot(T::Type, label, labels) = T[i == label for i in labels]
onehot(label, labels) = onehot(Int, label, labels)
onecold(pred, labels = 1:length(pred)) = labels[findfirst(pred, maximum(pred))]

chunks(r::UnitRange, step::Integer) = (step*(i-1)+1:step*i for i in 1:(r.stop÷step))
chunks(xs, step) = (xs[i] for i in chunks(1:length(xs), step))

initn(dims...) = randn(Float32, dims...)/1000

function train!(m, train, test = []; epoch = 1, batch = 10, η = 0.1)
    i = 0
    ∇ = zeros(length(train[1][2]))
    for _ in 1:epoch
      @progress for (x, y) in train
        i += 1
        pred = m(x)
        any(isnan, pred) && error("NaN")
        err = mse!(∇, pred, y)
        back!(m, ∇, x)
        i % batch == 0 && update!(m, η)
        i % 1000 == 0 && @show accuracy(m, test)
      end
    end
    return m
end

function accuracy(m, data)
  correct = 0
  for (x, y) in data
    onecold(m(x)) == onecold(y) && (correct += 1)
  end
  return correct/length(data)
end
