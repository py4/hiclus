STDOUT.sync = true
class Cluster
  attr_accessor :right,:left,:vec,:id
  def initialize(right=nil,left=nil,vec=nil,id=nil)
    @right = right
    @left = left
    @vec = vec
    @id = id
  end
end

def pearson_distance(vec1,vec2)
  sum1 = vec1.inject(:+)
  sum2 = vec2.inject(:+)
  sum1Sq = vec1.map { |n| n**2}.inject(:+).to_f
  sum2Sq = vec2.map { |n| n**2}.inject(:+).to_f
  pSum = (0..(vec1.count-1)).map { |i| vec1[i] * vec2[i] }.inject(:+)
  num = pSum - ((sum1*sum2).to_f/vec1.count)
  den = ((sum1Sq - ((sum1**2)/vec1.count)) * (sum2Sq - ((sum2**2)/vec1.count)))**0.5
  return 0 if den == 0
  return 1 - (num / den)
end

def dump_cluster(cluster,labels=nil,n=0)

  s = ""
  n.times { s += " " }
  if(cluster.id < 0)
    s += '-'
  else
    s += labels[cluster.id]
  end
  puts s
  dump_cluster(cluster.right,labels=labels,n=n+1) if cluster.right
  dump_cluster(cluster.left,labels=labels,n=n+1) if cluster.left
  
end

lines = File.read("blogdata.txt").lines
columns = lines.first.split("\t")
data = {}
lines[1..-1].each do |line|
  words = line.split("\t")
  data[words[0]] = words[1..-1].map { |n| n.to_f }
end

clusters = []
sims = {}
(0..(data.keys.count-1)).each do |i|
  clusters << Cluster.new(nil,nil,data[data.keys[i]],i)
end

cluster_id = -1
while clusters.count > 1
  min_pair = [0,1]
  min_distance = pearson_distance(clusters[0].vec,clusters[1].vec)
  (0..(clusters.count-1)).each do |i|
    ((i+1)..(clusters.count-1)).each do |j|
      d = (sims[[clusters[i].id,clusters[j].id]] ||= pearson_distance(clusters[i].vec,clusters[j].vec))
      if(d < min_distance)
        min_pair = [i,j]
        min_distance = d
      end
    end
  end
  new_vec = (0..(clusters[0].vec.count-1)).map { |i| (clusters[min_pair[0]].vec[i]+clusters[min_pair[1]].vec[i])/2.0 }
  new_cluster = Cluster.new(clusters[min_pair[0]],clusters[min_pair[1]],new_vec,cluster_id)
  cluster_id -= 1
  clusters -= [clusters[min_pair[0]],clusters[min_pair[1]]]
  clusters << new_cluster
end

dump_cluster(clusters.first,data.keys,0)






